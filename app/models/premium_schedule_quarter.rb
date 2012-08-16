class PremiumScheduleQuarter

  # The amount of interest that the government charges for guaranteeing the loan.
  PREMIUM_RATE = 0.02

  attr_reader :quarter, :total_quarters, :premium_schedule

  delegate :initial_draw_amount, to: :premium_schedule
  delegate :initial_draw_months, to: :premium_schedule
  delegate :repayment_duration, to: :premium_schedule
  delegate :second_draw_amount, to: :premium_schedule
  delegate :second_draw_months, to: :premium_schedule
  delegate :third_draw_amount, to: :premium_schedule
  delegate :third_draw_months, to: :premium_schedule
  delegate :fourth_draw_amount, to: :premium_schedule
  delegate :fourth_draw_months, to: :premium_schedule

  def initialize(quarter, total_quarters, premium_schedule)
    @quarter          = quarter
    @total_quarters   = total_quarters
    @premium_schedule = premium_schedule
  end

  def premium_amount
    if quarter <= total_quarters
      outstanding_capital = aggregate_outstanding_amount - capital_repaid_to_date
      outstanding_capital * (PREMIUM_RATE / 4)
    else
      Money.new(0)
    end
  end

  private

  def aggregate_outstanding_amount
    initial_draw_amount +
      tranche_drawdown(:second) + tranche_drawdown(:third) + tranche_drawdown(:fourth)
  end

  # return the outstanding amount on the specified tranche draw down
  # if it has come into effect in this, or a previous, quarter
  def tranche_drawdown(tranche_number)
    draw_amount = send("#{tranche_number}_draw_amount")
    draw_month = send("#{tranche_number}_draw_months")

    # draw down doesn't exist
    return Money.new(0) unless draw_amount && draw_month

    draw_quarter = draw_month / 3
    remaining_months = initial_draw_months - draw_month

    if draw_month <= 3 * quarter
      draw_amount - (draw_amount * ((3 * quarter) - draw_month)) / remaining_months
    else
      Money.new(0)
    end
  end

  def capital_repaid_to_date
    (initial_draw_amount / total_quarters) * quarter
  end

end
