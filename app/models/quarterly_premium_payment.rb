class QuarterlyPremiumPayment < BasePremiumPayment
  private

  def amount_of_drawdown_repaid(drawdown)
    if premium_schedule.repayment_holiday_active_at_month?(quarter.last_month)
      Money.new(0)
    else
      drawdown.amount * proportion_of_drawdown_repaid(drawdown.month)
    end
  end

  def proportion_of_drawdown_repaid(month_of_drawdown)
    months_of_drawdown_repayment_at_time_of_premium(month_of_drawdown).to_f / total_drawdown_repayment_months(month_of_drawdown)
  end

  def total_drawdown_repayment_months(month_of_drawdown)
    premium_schedule.repayment_duration - start_month_of_drawdown_repayment(month_of_drawdown)
  end

  def months_of_drawdown_repayment_at_time_of_premium(month_of_drawdown)
    quarter.last_month - start_month_of_drawdown_repayment(month_of_drawdown)
  end

  def start_month_of_drawdown_repayment(month_of_drawdown)
    premium_schedule.initial_capital_repayment_holiday > month_of_drawdown ? premium_schedule.initial_capital_repayment_holiday : month_of_drawdown
  end
end
