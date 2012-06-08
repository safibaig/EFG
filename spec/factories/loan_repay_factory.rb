FactoryGirl.define do
  factory :loan_repay do
    repaid_on '01/06/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed)
      new(loan)
    }
  end
end
