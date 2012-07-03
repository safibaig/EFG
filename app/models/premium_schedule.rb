class PremiumSchedule
  PREMIUM_RATE = 0.02

  def initialize(state_aid_calculation)
    @state_aid_calculation = state_aid_calculation
    @loan = state_aid_calculation.loan
  end

  attr_reader :loan, :state_aid_calculation

  delegate :initial_draw_year, to: :state_aid_calculation
  delegate :initial_draw_date, to: :loan
  delegate :initial_draw_amount, to: :state_aid_calculation
  delegate :initial_draw_months, to: :state_aid_calculation
  delegate :initial_capital_repayment_holiday, to: :state_aid_calculation
  delegate :second_draw_amount, to: :state_aid_calculation
  delegate :second_draw_months, to: :state_aid_calculation
  delegate :third_draw_amount, to: :state_aid_calculation
  delegate :third_draw_months, to: :state_aid_calculation
  delegate :fourth_draw_amount, to: :state_aid_calculation
  delegate :fourth_draw_months, to: :state_aid_calculation

  def premiums
    amount = state_aid_calculation.initial_draw_amount
    quarters = state_aid_calculation.initial_draw_months / 3

    Array.new(40) do |quarter|
      if quarter <= quarters
        outstanding_capital = amount - ((amount / quarters) * quarter)
        outstanding_capital * PREMIUM_RATE / 4
      else
        Money.new(0)
      end
    end
  end

  def subsequent_premiums
    premiums[1..-1]
  end

  def total_subsequent_premiums
    subsequent_premiums.sum
  end

  def total_premiums
    premiums.sum
  end
end
