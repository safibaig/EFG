class OutstandingDrawdownValue
  def initialize(args)
    @quarter             = args[:quarter]
    @repayment_frequency = args[:repayment_frequency]
    @drawdown            = args[:drawdown]
  end

  def amount
    drawdown.amount - amount_of_drawdown_repaid
  end

  private

  attr_reader :quarter, :repayment_frequency, :drawdown

  def amount_of_drawdown_repaid
    if premium_schedule.repayment_holiday_active_at_month?(quarter.last_month)
      Money.new(0)
    else
      drawdown.amount * proportion_of_drawdown_repaid
    end
  end

  def proportion_of_drawdown_repaid
    months_of_drawdown_repayment_at_time_of_premium.to_f / total_drawdown_repayment_months
  end

  def months_of_drawdown_repayment_at_time_of_premium
    # Number of complete loan repayment periods since premium schedule start
    complete_repayments = quarter.last_month.divmod(months_per_repayment_period).first

    # Number of months of repayment at this quarter against this drawdown
    months_of_repayment = (complete_repayments * months_per_repayment_period) - start_month_of_drawdown_repayment

    months_of_repayment > 0 ? months_of_repayment : 0
  end

  def months_per_repayment_period
    if repayment_frequency == RepaymentFrequency::InterestOnly
      # No repayment until the end of the loan
      premium_schedule.repayment_duration
    else
      repayment_frequency.months_per_repayment_period
    end
  end

  def total_drawdown_repayment_months
    premium_schedule.repayment_duration - start_month_of_drawdown_repayment
  end

  def start_month_of_drawdown_repayment
    premium_schedule.initial_capital_repayment_holiday > drawdown.month ? premium_schedule.initial_capital_repayment_holiday : drawdown.month
  end

  def premium_schedule
    drawdown.premium_schedule
  end
end
