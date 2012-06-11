FactoryGirl.define do
  factory :loan_demand_to_borrower do
    borrower_demanded_on '01/06/2012'
    borrower_demanded_amount 'No comment'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed)
      new(loan)
    }
  end
end
