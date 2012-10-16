FactoryGirl.define do
  factory :loan_state_change do
    loan
    state Loan::Eligible
    event_id 1
    modified_at Time.now
    association :modified_by, factory: :lender_user

    factory :accepted_loan_state_change do
      event_id 1
      state Loan::Eligible
    end

    factory :completed_loan_state_change do
      event_id 4
      state Loan::Completed
    end

    factory :offered_loan_state_change do
      event_id 5
      state Loan::Offered
    end

    factory :guaranteed_loan_state_change do
      event_id 7
      state Loan::Guaranteed
    end
  end
end
