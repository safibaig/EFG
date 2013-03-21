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

  attr_reader :drawdown, :quarter, :repayment_frequency, :repayment_duration, :repayment_holiday

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
    months_of_drawdown_repayment.to_f / total_drawdown_repayment_months
  end

  def months_of_drawdown_repayment
    # Number of complete loan repayment periods since premium schedule start
    complete_repayments = quarter.last_month.divmod(months_per_repayment_period).first

    # Number of months of repayment at this quarter against this drawdown
    months_of_repayment = (complete_repayments * months_per_repayment_period) - start_month_of_drawdown_repayment

    months_of_repayment > 0 ? months_of_repayment : 0
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
    repayment_holiday > drawdown.month ? repayment_holiday : drawdown.month
  end
end
