class LenderAdmin < User
  include LenderAdminPermissions

  belongs_to :lender

  validates_presence_of :lender
end
