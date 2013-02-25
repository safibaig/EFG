class BankersRoundingMoney < Money
  # Use bankers' rounding:
  # http://en.wikipedia.org/wiki/Rounding#Round_half_to_even
  def initialize(amount)
    super amount.round(0, :banker)
  end
end
