class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    has_many :leaves
    has_many :subordinates, class_name: "User", foreign_key: "head_id"
    belongs_to :head, class_name: "User", optional: true

    enum status: ['Applied', 'Approved', 'Rejected']
end
