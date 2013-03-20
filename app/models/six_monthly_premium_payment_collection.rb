class SixMonthlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def premium_amount_for_quarter(quarter)
    super
    SixMonthlyPremiumPayment.new(quarter, premium_schedule).amount
  end
end
