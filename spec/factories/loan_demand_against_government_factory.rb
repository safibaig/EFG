FactoryGirl.define do
  factory :loan_demand_against_government do
    dti_demand_outstanding 10_000
    dti_demanded_on Date.today
    dti_ded_code 'A.10.10'

    initialize_with {
      loan = FactoryGirl.create(:loan, :guaranteed, :lender_demand)
      new(loan)
    }

    factory :sflg_loan_demand_against_government do
      dti_interest 1000_00
      dti_break_costs 500_00

      initialize_with {
        loan = FactoryGirl.create(:loan, :sflg, :guaranteed, :lender_demand)
        new(loan)
      }
    end

    factory :legacy_sflg_loan_demand_against_government do
      dti_interest 1000_00
      dti_break_costs 500_00

      initialize_with {
        loan = FactoryGirl.create(:loan, :legacy_sflg, :guaranteed, :lender_demand)
        new(loan)
      }
    end
  end
end
