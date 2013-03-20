class InterestOnlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def repayment_frequency
    RepaymentFrequency::InterestOnly
  end
end
