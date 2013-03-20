class MonthlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def repayment_frequency
    RepaymentFrequency::Monthly
  end
end

