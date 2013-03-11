class PremiumMoney < Money

  # ensure half pennies round down
  # 0.1550 becomes £0.15, not £0.16
  # 0.1555 becomes £0.16
  def initialize(amount)
    modified_amount = amount * 100
    if (modified_amount.modulo(1) * 100).to_i <= 50
      modified_amount = modified_amount.floor
    end
    super modified_amount
  end

end
