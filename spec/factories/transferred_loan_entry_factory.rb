FactoryGirl.define do
  factory :transferred_loan_entry do
    declaration_signed true
    amount 50000
    repayment_duration({ months: 24 })
    repayment_frequency_id 1
    maturity_date '01/01/2012'

    initialize_with {
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation)
      loan = FactoryGirl.build(:loan, :incomplete, :transferred, state_aid_calculations: [ state_aid_calculation ])
      new(loan)
    }
  end
end
