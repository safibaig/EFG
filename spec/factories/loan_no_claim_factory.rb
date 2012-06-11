FactoryGirl.define do
  factory :loan_no_claim do
    no_claim_on '01/06/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan, :lender_demand)
      new(loan)
    }
  end
end
