class Lender < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'
  has_many :lender_admins
  has_many :lender_users
  has_many :loans
  has_many :loan_allocations

  scope :order_by_name, order(:name)
end
