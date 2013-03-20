class QuarterlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def premium_amount_for_quarter(quarter)
    super
    QuarterlyPremiumPayment.new(quarter, premium_schedule).amount
  end
end
