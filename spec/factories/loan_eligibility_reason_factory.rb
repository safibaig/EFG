FactoryGirl.define do
  factory :loan_ineligibility_reason do
    loan
    reason "Reason text"
  end
end
