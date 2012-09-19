class UserAudit < ActiveRecord::Base
  belongs_to :user
  belongs_to :modified_by, class_name: "User"
end
