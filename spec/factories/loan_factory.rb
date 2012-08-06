FactoryGirl.define do
  factory :loan do
    state Loan::Eligible
    lender
    legal_form_id 1
    loan_allocation
    loan_category_id 1
    repayment_frequency_id 4
    reason_id 1
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
    sequence(:legacy_id) { |n| n }
    created_at { Time.now }
    updated_at { Time.now }
    legacy_small_loan false

    trait :eligible do
      state Loan::Eligible
    end

    trait :rejected do
      state Loan::Rejected
    end

    trait :cancelled do
      state Loan::Cancelled
      cancelled_reason_id 1
      cancelled_comment 'Comment'
      cancelled_on { Date.today }
    end

    trait :completed do
      state Loan::Completed
    end

    trait :incomplete do
      state Loan::Incomplete
    end

    trait :offered do
      state Loan::Offered
      facility_letter_sent true
      facility_letter_date { Date.today }
    end

    trait :guaranteed do
      state Loan::Guaranteed
      received_declaration true
      signed_direct_debit_received true
      first_pp_received true
      initial_draw_date { Date.today }
      initial_draw_value Money.new(10000)
      maturity_date { 10.years.from_now }
    end

    trait :removed do
      state Loan::Removed
      remove_guarantee_outstanding_amount Money.new(10_000_00)
      remove_guarantee_on { Date.today }
      remove_guarantee_reason 'reason'
    end

    trait :repaid do
      state Loan::Repaid
      repaid_on { Date.today }
    end

    trait :demanded do
      state Loan::Demanded
      amount_demanded Money.new(10_000_00)
      dti_demanded_on { Date.today }
      dti_ded_code 'ABC'
      dti_reason 'reason'
    end

    trait :not_demanded do
      state Loan::NotDemanded
      no_claim_on { Date.today }
    end

    trait :lender_demand do
      state Loan::LenderDemand
      borrower_demanded_on { Date.today }
      borrower_demand_outstanding Money.new(10_000_00)
    end

    trait :settled do
      state Loan::Settled
      settled_on { Date.today }
    end

    trait :recovered do
      state Loan::Recovered
      recovery_on { Date.today }
    end

    trait :realised do
      state Loan::Realised
      realised_money_date { Date.today }
    end

    trait :repaid_from_transfer do
      state Loan::RepaidFromTransfer
    end

    trait :transferred do
      reference 'ABCDEFG+02'
      state Loan::Incomplete
    end

    trait :with_state_aid_calculation do
      after(:build) do |loan|
        loan.state_aid_calculations = [ FactoryGirl.build(:state_aid_calculation) ]
      end
    end

    trait :sflg do
      reference 'ABC1234-01'
      loan_source Loan::SFLG_SOURCE
      loan_scheme Loan::SFLG_SCHEME
    end

    trait :legacy_sflg do
      reference '123456'
      loan_source Loan::LEGACY_SFLG_SOURCE
      loan_scheme Loan::SFLG_SCHEME
    end

    trait :efg do
      reference 'ABC1234+01'
      loan_source Loan::SFLG_SOURCE
      loan_scheme Loan::EFG_SCHEME
    end

  end
end
