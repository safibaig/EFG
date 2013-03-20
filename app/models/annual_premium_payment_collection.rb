class AnnualPremiumPaymentCollection < BasePremiumPaymentCollection
  def repayment_frequency
    RepaymentFrequency::Annually
  end
end
