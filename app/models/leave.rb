class Leave < ApplicationRecord
	belongs_to :user

	def status_name
		User.statuses.keys[self.status]
	end
end
