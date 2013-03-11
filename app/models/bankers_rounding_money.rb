class BankersRoundingMoney < Money
  # Round exact half pennies to the nearest even penny (bankers' rounding):
  # http://en.wikipedia.org/wiki/Rounding#Round_half_to_even
  # Otherwise, round to the nearest penny as expected.
  def initialize(amount_in_pennies)
    whole, fraction = amount_in_pennies.divmod(1)

    rounded_amount_in_pennies =
      if fraction == 0.5 && whole.to_i.even?
        amount_in_pennies.floor
      else
        amount_in_pennies.round
      end

    super rounded_amount_in_pennies
  end
end
