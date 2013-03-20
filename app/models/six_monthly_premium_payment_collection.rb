class SixMonthlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def repayment_frequency
    RepaymentFrequency::SixMonthly
  end
end
