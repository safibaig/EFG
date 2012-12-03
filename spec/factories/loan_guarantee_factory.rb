FactoryGirl.define do
  factory :loan_guarantee do
    received_declaration true
    signed_direct_debit_received true
    first_pp_received true
    initial_draw_date Date.today
    maturity_date 6.months.from_now.to_date

    initialize_with {
      loan = FactoryGirl.build(:loan, :offered)
      new(loan)
    }
  end
end
