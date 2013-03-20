class MonthlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def premium_amount_for_quarter(quarter)
    super
    MonthlyPremiumPayment.new(quarter, premium_schedule).amount
  end
end

