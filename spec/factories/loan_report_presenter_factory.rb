FactoryGirl.define do
  factory :loan_report_presenter do
    states Loan::States
    loan_sources ["S"]
    loan_scheme "E"
    lender_ids [1]
    allowed_lender_ids [1]
  end
end
