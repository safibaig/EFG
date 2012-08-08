class Lender < ActiveRecord::Base
  has_many :lender_admins
  has_many :lender_users
  has_many :loans
  has_many :loan_allocations

  scope :order_by_name, order(:name)
end
