class LenderUser < User
  include LenderUserPermissions

  belongs_to :lender

  validates_presence_of :lender

  def lenders
    [ lender ]
  end
end
