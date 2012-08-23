FactoryGirl.define do
  factory :loan_state_change do
    loan
    state Loan::Eligible
    event_id 1
    modified_on Date.today
    association :modified_by, factory: :lender_user
  end
end
