class Lender < ActiveRecord::Base
  has_many :loans
  has_many :users
  has_many :loan_allocations
end
