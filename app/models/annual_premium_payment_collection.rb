class AnnualPremiumPaymentCollection < BasePremiumPaymentCollection
  def premium_amount_for_quarter(quarter)
    super
    AnnualPremiumPayment.new(quarter, premium_schedule).amount
  end
end
