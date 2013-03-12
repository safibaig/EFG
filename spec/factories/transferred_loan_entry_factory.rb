FactoryGirl.define do
  factory :transferred_loan_entry do
    declaration_signed true
    amount 50000
    repayment_duration({ months: 24 })
    repayment_frequency_id 3

    initialize_with {
      premium_schedule = FactoryGirl.create(:premium_schedule)
      loan = FactoryGirl.create(:loan, :incomplete, :transferred, premium_schedules: [ premium_schedule ])
      new(loan)
    }
  end
end
