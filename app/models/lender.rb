class Lender < ActiveRecord::Base
  has_many :loans
  has_many :users, class_name: 'LenderUser'
  has_many :loan_allocations
end
