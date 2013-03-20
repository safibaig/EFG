class QuarterlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def repayment_frequency
    RepaymentFrequency::Quarterly
  end
end
