FactoryGirl.define do
  factory :loan_transfer do
    amount 10000.00
    new_amount 8000.00
    reference "ABC123"
    facility_letter_date '20/05/2011'
    declaration_signed 'true'
    lender
  end
end