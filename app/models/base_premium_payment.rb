class BasePremiumPayment
  def initialize(quarter, premium_schedule)
    @quarter = quarter
    @premium_schedule = premium_schedule
  end

  def amount
    amount_in_pounds = aggregate_outstanding_amount_at_time_of_premium_payment.to_d
    BankersRoundingMoney.new((amount_in_pounds * 100) * premium_schedule.premium_rate_per_quarter)
  end

  private
  attr_reader :quarter, :premium_schedule

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
end
