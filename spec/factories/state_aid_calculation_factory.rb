FactoryGirl.define do
  factory :state_aid_calculation do
    loan
    initial_draw_year 2012
    initial_draw_amount { |o| o.loan.amount }
    initial_draw_months 12

    factory :rescheduled_state_aid_calculation do
      premium_cheque_month '03/2012'
    end
  end
end
