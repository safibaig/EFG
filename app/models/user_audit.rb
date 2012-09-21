class UserAudit < ActiveRecord::Base

  INITIAL_LOGIN = "Initial login"
  PASSWORD_CHANGED = "Password Change"

  belongs_to :user
  belongs_to :modified_by, class_name: "User"

  attr_accessible :user_id, :function, :modified_by, :password

  validates_presence_of :user_id, :function, :modified_by_id, :password
end
