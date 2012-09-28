class LenderAdmin < User
  include Expertable
  include LenderAdminPermissions

  belongs_to :lender

  validates_presence_of :lender

  def active_for_authentication?
    super && lender.active
  end
end
