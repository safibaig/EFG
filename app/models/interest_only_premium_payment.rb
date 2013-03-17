class InterestOnlyPremiumPayment < BasePremiumPayment
  def amount_of_drawdown_repaid(drawdown)
    # Only the interest is paid, no loan repayment occurs until the end of the loan term
    Money.new(0)
  end
end
