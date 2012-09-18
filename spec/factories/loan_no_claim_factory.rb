FactoryGirl.define do
  factory :loan_no_claim do
    no_claim_on Date.new(2012, 6, 1)

    initialize_with {
      loan = FactoryGirl.build(:loan, :lender_demand)
      new(loan)
    }
  end
end
