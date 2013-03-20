class PremiumPayment
  def initialize(quarter, premium_schedule, repayment_frequency)
    @quarter = quarter
    @premium_schedule = premium_schedule
    @repayment_frequency = repayment_frequency
  end

  def amount
    amount_in_pounds = aggregate_outstanding_amount_at_time_of_premium_payment.to_d
    BankersRoundingMoney.new((amount_in_pounds * 100) * premium_schedule.premium_rate_per_quarter)
  end

  private
  attr_reader :quarter, :premium_schedule, :repayment_frequency

  def amount_of_drawdown_repaid(drawdown)
    if premium_schedule.repayment_holiday_active_at_month?(quarter.last_month)
      Money.new(0)
    else
      drawdown.amount * proportion_of_drawdown_repaid(drawdown.month)
    end
  end

  def proportion_of_drawdown_repaid(month_of_drawdown)
    months_of_drawdown_repayment_at_time_of_premium(month_of_drawdown).to_f / total_drawdown_repayment_months(month_of_drawdown)
  end

  def total_drawdown_repayment_months(month_of_drawdown)
    premium_schedule.repayment_duration - start_month_of_drawdown_repayment(month_of_drawdown)
  end

  def start_month_of_drawdown_repayment(month_of_drawdown)
    premium_schedule.initial_capital_repayment_holiday > month_of_drawdown ? premium_schedule.initial_capital_repayment_holiday : month_of_drawdown
  end

  def aggregate_outstanding_amount_at_time_of_premium_payment
    drawdowns_taken_before_or_during_premium_payment_quarter.inject(Money.new(0)) do |sum, drawdown|
      sum + amount_outstanding_for_drawdown(drawdown)
    end
  end

  def drawdowns_taken_before_or_during_premium_payment_quarter
    premium_schedule.drawdowns.select {|drawdown| drawdown.month <= quarter.last_month }
  end

  def amount_outstanding_for_drawdown(drawdown)
    drawdown.amount - amount_of_drawdown_repaid(drawdown)
  end

  def months_of_drawdown_repayment_at_time_of_premium(month_of_drawdown)
    # Number of complete loan repayment periods since premium schedule start
    complete_repayments = quarter.last_month.divmod(months_per_repayment_period).first

    # Number of months of repayment at this quarter against this drawdown
    months_of_repayment = (complete_repayments * months_per_repayment_period) - start_month_of_drawdown_repayment(month_of_drawdown)

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
end
