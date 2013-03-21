class PremiumPayment
  def initialize(args)
    @quarter             = args[:quarter]
    @premium_schedule    = args[:premium_schedule]
    @repayment_frequency = args[:repayment_frequency]
  end

  def amount
    amount_in_pounds = aggregate_outstanding_amount_at_time_of_premium_payment.to_d
    BankersRoundingMoney.new((amount_in_pounds * 100) * premium_schedule.premium_rate_per_quarter)
  end

  private
  attr_reader :quarter, :premium_schedule, :repayment_frequency

  def aggregate_outstanding_amount_at_time_of_premium_payment
    premium_schedule.drawdowns_taken_by_quarter(quarter).inject(Money.new(0)) do |sum, drawdown|
      sum + drawdown.outstanding_value(quarter, repayment_frequency)
    end
  end
end
