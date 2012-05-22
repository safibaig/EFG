class Lender < ActiveRecord::Base
  has_many :loans
  has_many :users
end
