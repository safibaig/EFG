FactoryGirl.define do
  factory :transferred_loan_entry do
    declaration_signed true
    amount 50000
    repayment_duration({ months: 24 })
    repayment_frequency_id 3

    initialize_with {
      state_aid_calculation = FactoryGirl.create(:state_aid_calculation)
      loan = FactoryGirl.create(:loan, :incomplete, :transferred, state_aid_calculations: [ state_aid_calculation ])
      new(loan)
    }
  end
end
