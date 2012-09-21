FactoryGirl.define do
  factory :eligibility_decision_email do
    email "joe@example.com"

    initialize_with {
      loan = FactoryGirl.build(:loan, :eligible)
      new(loan)
    }
  end

  factory :ineligible_eligibility_decision_email, parent: :eligibility_decision_email do
    initialize_with {
      loan = FactoryGirl.build(:loan, :rejected)
      new(loan)
    }
  end
end