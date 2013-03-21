class TrancheDrawdown
  attr_reader :amount, :month, :premium_schedule

  def initialize(args)
    @amount           = args[:amount]
    @month            = args[:month]
    @premium_schedule = args[:premium_schedule]
  end

  def outstanding_value(quarter, repayment_frequency)
    OutstandingDrawdownValue.new(
      quarter: quarter,
      repayment_frequency: repayment_frequency,
      drawdown: self
    ).amount
  end
end
