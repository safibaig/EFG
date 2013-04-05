FactoryGirl.define do
  factory :premium_schedule do
    loan
    initial_draw_year 2012
    initial_draw_amount { |o| o.loan.amount }
    repayment_duration 12
    calc_type 'S'
    legacy_premium_calculation true

    factory :rescheduled_premium_schedule do
      calc_type 'R'
      initial_draw_year nil
      premium_cheque_month { Date.today.next_month.strftime('%m/%Y') }
    end

    trait :with_drawdowns do
      initial_draw_amount { |o| o.loan.amount / 2 }
      second_draw_amount { |o| o.initial_draw_amount / 2 }
      second_draw_months 6
    end
  end
end
