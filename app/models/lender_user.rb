class LenderUser < User
  belongs_to :lender

  validates_presence_of :lender
end
