# encoding: utf-8

FactoryGirl.define do
  factory :loan_demand_to_borrower do
    amount_demanded '£1,234.56'
    borrower_demanded_on '01/06/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed)
      new(loan)
    }
  end
end
