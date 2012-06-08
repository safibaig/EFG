FactoryGirl.define do
  factory :loan do
    state Loan::Eligible
    lender
    viable_proposition true
    would_you_lend true
    collateral_exhausted true
    amount 12345
    lender_cap_id 1
    repayment_duration({ months: 24 })
    turnover 12345
    trading_date 2.years.ago
    sic_code '12345'
    loan_category_id 1
    reason_id 1
    previous_borrowing true
    private_residence_charge_required false
    personal_guarantee_required false

    trait :eligible do
      state Loan::Eligible
    end

    trait :completed do
      state Loan::Completed
    end

    trait :offered do
      state Loan::Offered
    end

    trait :guaranteed do
      state Loan::Guaranteed
    end

    trait :lender_demand do
      state Loan::LenderDemand
    end
  end
end
