class PremiumMoney < Money

  # ensure half pennies round down
  # 0.1550 becomes £0.15, not £0.16
  # 0.1555 becomes £0.16
  def initialize(amount)
    super amount.modulo(1) == 0.5 ?  amount.floor : amount.round
  end

end
