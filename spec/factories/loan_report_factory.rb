FactoryGirl.define do
  factory :loan_report do
    loan_state Loan::Eligible
    created_by_user_id 1
    loan_type "S"
    loan_scheme "E"
    lender_id 1
  end
end
