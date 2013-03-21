class TrancheDrawdown
  attr_reader :amount, :month

  def initialize(amount, month)
    @amount = amount
    @month  = month
  end
end
