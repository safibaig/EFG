FactoryGirl.define do
  factory :loan_demand_against_government do
    dti_demand_outstanding 10_000
    dti_demanded_on Date.today
    dti_ded_code 'A.10.10'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed, :lender_demand)
      new(loan)
    }
  end
end
