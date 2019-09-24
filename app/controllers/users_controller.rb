class UsersController < ApplicationController
	before_action :authenticate_user!

	def profile
		# fetching the subordinates of the head so that he/she can approve/reject the holidays
		@subordinates = User.where(head_id: current_user.id)
	end

	def apply_leave
		# counting the holidays
		no_of_days = (Date.strptime(params['end_date'],"%m/%d/%Y") - Date.strptime(params['start_date'], "%m/%d/%Y")).to_i + 1
		leaves_diff = current_user.credited_leaves - current_user.taken_leaves - no_of_days
		response = {}
		# if no leaves is extant
		if leaves_diff < 0
			response = {:status => 200, 'message' => "Sorry you don't have sufficient leaves"}
		else
			# saving reason, from to dates, status
			current_user.leaves.create(reason: params['reason'], from_to: params['start_date'] + ' to ' + params['end_date'], status: params['status'])
			# saving applied_date
			current_user.leaves.last.update(applied_date: current_user.leaves.last.created_at.to_date)
			# seending the email to both subordinate and his/her head
			LeaveMailer.apply_leave_email(current_user.name, current_user.email, no_of_days, params['start_date'] + ' to ' + params['end_date'], current_user.head.email).deliver_now
			response = {:status => 200, 'message' => "You have successfully applied"}	
		end
		render status: response[:status], json: response
	end

	def find_leaves_record
		leave = Leave.find_by(id: params['leave_id']).as_json(methods: [ :status_name])
		if leave.present?
			# adding name of the head in the json
			response = {:status => 200, key: 1, data: leave.merge!('head_name' => current_user.head.present? ? current_user.head.name : 'not assigned head any yet')}
		else
			response = {:status => 200, key: 0, data: "Sorry can't able to retrieve record"}
		end
		render status: response[:status], json: response
	end

	def edit_leaves
		leave = Leave.find_by(id: params['leave_id'])
		response = {}
		if leave.present?
			# if leave's status is approved/rejected then you can't edit it
			if leave.status != 0
				response = {:status => 200, key: 0, data: "Sorry you can't update the leaves as your leaves have been "+User.statuses.keys[leave.status].downcase}
			else
				# count new one holidays
				new_no_of_days_leaves = (Date.strptime(params['edit_end_date'],"%m/%d/%Y") - Date.strptime(params['edit_start_date'], "%m/%d/%Y")).to_i + 1
				# count old one holidays
				old_no_of_days_leaves = (Date.strptime(leave.from_to.split('to')[1].strip,"%m/%d/%Y") - Date.strptime(leave.from_to.split('to')[0].strip, "%m/%d/%Y")).to_i + 1
				# update the from_to, reason
				leave.update(from_to: params['edit_start_date'] +' to '+params['edit_end_date'], reason: params['reason'])
				# updte the date in the attribute applied_date
				leave.update(applied_date: leave.updated_at.to_date)
				# send email 
				LeaveMailer.edit_leave_email(current_user.name, current_user.email, new_no_of_days_leaves, params['edit_start_date'] + ' to ' + params['edit_end_date'], current_user.head.email).deliver_now
				response = {:status => 200, key: 1, data: "Leaves Updated Successsfully "}
			end
		else
			response = {:status => 200, key: 0, data: "Sorry can't able to retrieve record"}
		end
		render status: response[:status], json: response
	end

	def cancel_leaves
		leave = Leave.find_by(id: params['leave_id'])
		response = {}
		if leave.present?
			# if leave's status is approved/rejected then you can't cancel it
			if leave.status != 0
				response = {:status => 200, key: 0, data: "Sorry you can't update the leaves as your leaves have been "+User.statuses.keys[leave.status].downcase}
			else
				# count days
				no_of_days = (Date.strptime(leave.from_to.split('to')[1].strip,"%m/%d/%Y") - Date.strptime(leave.from_to.split('to')[0].strip, "%m/%d/%Y")).to_i + 1
				# delete the record of the cancelled holidays by the subordinate
				leave.delete
				# send the email
				LeaveMailer.cancel_leave_email(current_user.name, current_user.email, no_of_days, params['from_to'], current_user.head.email).deliver_now
				response = {:status => 200, key: 1, data: "Leaves deleted successsfully "}
			end
		end
		render status: response[:status], json: response
	end

	def final_action
		leave = Leave.find_by(id: params['leave_id'])
		user = User.find_by(id: params['user_id'])
		response = {}
		if leave.present? && user.present?
			if params['status'].to_i == 1 # if approved then make changes
				# counting the no. of holidays applied by the employee
				no_of_days = (Date.strptime(leave.from_to.split('to')[1].strip,"%m/%d/%Y") - Date.strptime(leave.from_to.split('to')[0].strip, "%m/%d/%Y")).to_i + 1
				user.update(taken_leaves: user.taken_leaves + no_of_days) # updating the taken leaves
				leave.update(status: params['status'])
				LeaveMailer.approved_email(user.name, user.email, no_of_days, leave.from_to, current_user.email).deliver_now
				response = {:status => 200, key: 1}
			elsif params['status'].to_i == 2  # if rejected
				# counting the no. of holidays applied by the employee
				no_of_days = (Date.strptime(leave.from_to.split('to')[1].strip,"%m/%d/%Y") - Date.strptime(leave.from_to.split('to')[0].strip, "%m/%d/%Y")).to_i + 1
				# updating the taken leaves if head inadvertently approved
				user.update(taken_leaves: user.taken_leaves - no_of_days) if params['rejected_approved_holidays'].to_i == 1
				leave.update(status: params['status'])
				LeaveMailer.rejected_email(user.name, user.email, no_of_days, leave.from_to, current_user.email).deliver_now
				response = {:status => 200, key: 1}
			end
		else
			response = {:status => 200, key: 0, data: 'Records did not find'}
		end
		render status: response[:status], json: response
	end
end
