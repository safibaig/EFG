class MonthlyPremiumPayment < BasePremiumPayment
  private
  
  def months_per_repayment_period
    1
  end
end
