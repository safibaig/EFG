class QuarterlyPremiumPayment < BasePremiumPayment
  private

  def months_per_repayment_period
    3
  end
end
