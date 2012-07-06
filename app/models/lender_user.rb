class LenderUser < User
  include LenderUserPermissions

  belongs_to :lender

  validates_presence_of :lender
end
