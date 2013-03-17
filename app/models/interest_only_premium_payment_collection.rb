class InterestOnlyPremiumPaymentCollection < BasePremiumPaymentCollection
  def premium_amount_for_quarter(quarter)
    super
    InterestOnlyPremiumPayment.new(quarter, premium_schedule).amount
  end
end
