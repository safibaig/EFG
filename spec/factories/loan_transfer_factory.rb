FactoryGirl.define do
  factory :loan_transfer do
    amount 1000000
    new_amount 800000
    reference "D54QT9C+01"
    facility_letter_date '20/05/2011'
    declaration_signed 'true'
    lender

    initialize_with {
      new(Loan.new)
    }
  end
end