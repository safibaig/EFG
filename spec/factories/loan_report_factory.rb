FactoryGirl.define do
  factory :loan_report do
    state "All"
    # created_by_user_id "All"
    loan_source "S"
    loan_scheme "E"
    lender_id "All"
  end
end
