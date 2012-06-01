FactoryGirl.define do
  factory :loan_offer do
    facility_letter_date '01/01/2012'
    facility_letter_sent true

    initialize_with {
      loan = FactoryGirl.build(:loan, :completed)
      new(loan)
    }
  end
end
