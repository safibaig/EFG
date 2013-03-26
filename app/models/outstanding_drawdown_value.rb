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

  attr_reader :drawdown, :quarter, :repayment_frequency

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

  def repayment_duration
    # Six monthly and annual repayment loans with a repayment duration which
    # isn't a multiple of the repayment frequency get rounded up the nearest
    # whole repayment period. E.g. an annual loan with a repayment duration of
    # 68 months gets rounded up to the nearest 12 (72)
    if [RepaymentFrequency::SixMonthly, RepaymentFrequency::Annually].include? repayment_frequency and
         @repayment_duration % months_per_repayment_period != 0
      (@repayment_duration.div(months_per_repayment_period) + 1) * months_per_repayment_period
    else
      @repayment_duration
    end
  end

  def repayment_holiday
    # If the payment holiday is not a multiple of the repayment frequency, it
    # gets rounded down to the last repayment month. E.g. For a six monthly
    # loan a holiday of 8 months becomes 6 months. For a quarterly loan a
    # holiday of 2 months becomes 0 months.
    @repayment_holiday.div(months_per_repayment_period) * months_per_repayment_period
  end
end
