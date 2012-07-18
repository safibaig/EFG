# encoding: utf-8

FactoryGirl.define do
  factory :loan_demand_to_borrower do
    borrower_demanded_on '01/06/2012'
    borrower_demand_outstanding '£1,234.56'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed)
      new(loan)
    }
  end
end
