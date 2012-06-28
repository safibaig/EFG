FactoryGirl.define do
  factory :loan do
    state Loan::Eligible
    lender
    legal_form_id 1
    loan_allocation
    loan_category_id 1
    repayment_frequency_id 4
    reason_id 1
    reference 'ABC123'
    business_name 'Acme'
    trading_name 'Emca'
    company_registration "B1234567890"
    postcode "EC1R 4RP"
    non_validated_postcode "AB1 2CD"
    town "London"
    viable_proposition true
    would_you_lend true
    collateral_exhausted true
    amount 12345
    repayment_duration({ months: 24 })
    maturity_date 10.years.from_now
    turnover 12345
    trading_date 2.years.ago
    sic_code '12345'
    previous_borrowing true
    private_residence_charge_required false
    personal_guarantee_required false
    state_aid 10000
    state_aid_is_valid true
    fees 50000
    created_at { Time.now }
    updated_at { Time.now }

    trait :eligible do
      state Loan::Eligible
    end

    trait :completed do
      state Loan::Completed
    end

    trait :incomplete do
      state Loan::Incomplete
    end

    trait :offered do
      state Loan::Offered
    end

    trait :guaranteed do
      state Loan::Guaranteed
    end

    trait :demanded do
      state Loan::Demanded
    end

    trait :lender_demand do
      state Loan::LenderDemand
    end
  end
end
