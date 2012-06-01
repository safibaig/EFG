FactoryGirl.define do
  factory :loan_entry do
    declaration_signed true
    business_name "Widgets PLC"
    legal_form_id 1
    interest_rate_type_id 1
    interest_rate 5.00
    fees 1000
    repayment_frequency_id 1
    postcode 'EC1R 4RP'
    maturity_date '01/01/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan)
      new(loan)
    }
  end
end
