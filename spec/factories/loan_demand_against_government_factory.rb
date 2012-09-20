FactoryGirl.define do
  factory :loan_demand_against_government do
    amount_demanded 10_000
    dti_demanded_on '1/1/11'
    dti_ded_code 'A.10.10'

    initialize_with {
      loan = FactoryGirl.build(:loan, :lender_demand)
      new(loan)
    }
  end
end
