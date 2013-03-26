class OutstandingDrawdownValue
  def initialize(args)
    @drawdown            = args[:drawdown]
    @quarter             = args[:quarter]
    @repayment_frequency = args[:repayment_frequency]
    @repayment_duration  = args[:repayment_duration]
    @repayment_holiday   = args[:repayment_holiday]
  end

  def amount
    return Money.new(0) if drawdown.month > quarter.last_month
    drawdown.amount - amount_of_drawdown_repaid
  end

  private

  attr_reader :drawdown, :quarter, :repayment_frequency, :repayment_duration

  def amount_of_drawdown_repaid
    if repayment_holiday_active?
      Money.new(0)
    else
      drawdown.amount * proportion_of_drawdown_repaid
    end
  end

  def repayment_holiday_active?
    repayment_holiday >= quarter.last_month
  end

  def proportion_of_drawdown_repaid
    months_of_drawdown_repayment_so_far.to_f / total_drawdown_repayment_months
  end

  def months_of_drawdown_repayment_so_far
    months_from_start_until_quarter = quarter.last_month - start_month_of_drawdown_repayment
    months_from_start_until_quarter = 0 if months_from_start_until_quarter < 0
    months_from_start_until_quarter.div(months_per_repayment_period) * months_per_repayment_period
  end

  def months_per_repayment_period
    if repayment_frequency == RepaymentFrequency::InterestOnly
      # No repayment until the end of the loan
      repayment_duration
    else
      repayment_frequency.months_per_repayment_period
    end
  end

  def total_drawdown_repayment_months
    repayment_duration - start_month_of_drawdown_repayment
  end

  def start_month_of_drawdown_repayment
    # For the purposes of calculating repayment rate, drawdowns taken within
    # the payment period "roll back" to the beginning of the payment period.
    # E.g. for an annual loan a drawdown in months 1-11 is treated as a
    # drawdown in month 0.
    whole_periods_elapsed = drawdown.month.div(months_per_repayment_period)
    effective_drawdown_month = whole_periods_elapsed * months_per_repayment_period
    repayment_holiday > effective_drawdown_month ? repayment_holiday : effective_drawdown_month
  end

  def repayment_holiday
    # If the payment holiday is not a multiple of the repayment frequency, it
    # gets rounded down to the last repayment month. E.g. For a six monthly
    # loan a holiday of 8 months becomes 6 months. For a quarterly loan a
    # holiday of 2 months becomes 0 months.
    @repayment_holiday.div(months_per_repayment_period) * months_per_repayment_period
  end
end
