class LeaveMailer < ApplicationMailer
	default from: 'vivek@mapprr.com'

	def apply_leave_email(receiver, receiver_email_id, no_of_days, from_to, head_email_id)
		@receiver = receiver
		@no_of_days = no_of_days
		@from_to = from_to
    mail(from: 'vivek@mapprr.com', to: receiver_email_id, :bcc => head_email_id, subject: 'Leave Application')
  end

	def edit_leave_email(receiver, receiver_email_id, no_of_days, from_to, head_email_id)
		@receiver = receiver
	  @no_of_days = no_of_days
	  @from_to = from_to
  	mail(from: 'vivek@mapprr.com', to: receiver_email_id, :bcc => head_email_id, subject: 'Update on leave application')
	end

	def cancel_leave_email(receiver, receiver_email_id, no_of_days, from_to, head_email_id)
		@receiver = receiver
	  @no_of_days = no_of_days
	  @from_to = from_to
  	mail(from: 'vivek@mapprr.com', to: receiver_email_id, :bcc => head_email_id, subject: 'Update on leave application')
	end

  def approved_email(receiver, receiver_email_id, no_of_days, from_to, head_email_id)
    @receiver = receiver
    @no_of_days = no_of_days
    @from_to = from_to
    mail(from: 'vivek@mapprr.com', to: receiver_email_id, :bcc => head_email_id, subject: 'Update on leave application')
  end

  def rejected_email(receiver, receiver_email_id, no_of_days, from_to, head_email_id)
    @receiver = receiver
    @no_of_days = no_of_days
    @from_to = from_to
    mail(from: 'vivek@mapprr.com', to: receiver_email_id, :bcc => head_email_id, subject: 'Update on leave application')
  end
end
