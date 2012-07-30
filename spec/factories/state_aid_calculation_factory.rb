FactoryGirl.define do
  factory :state_aid_calculation do
    loan
    initial_draw_year 2012
    initial_draw_amount { |o| o.loan.amount }
    initial_draw_months 12

    factory :rescheduled_state_aid_calculation do
      rescheduling true
      initial_draw_year nil
      premium_cheque_month { Date.today.next_month.strftime('%m/%Y') }
    end
  end
end
