class LenderUser < User
  include Expertable
  include LenderUserPermissions

  belongs_to :lender

  validates_presence_of :lender

  def active_for_authentication?
    super && lender.active
  end

  def lenders
    [ lender ]
  end
end
