class PremiumScheduleQuarter

  attr_reader :quarter, :total_quarters, :premium_schedule_generator, :initial_capital_repayment_holiday

  delegate :initial_draw_amount, to: :premium_schedule_generator
  delegate :repayment_duration, to: :premium_schedule_generator
  delegate :repayment_duration, to: :premium_schedule_generator
  delegate :second_draw_amount, to: :premium_schedule_generator
  delegate :second_draw_months, to: :premium_schedule_generator
  delegate :third_draw_amount, to: :premium_schedule_generator
  delegate :third_draw_months, to: :premium_schedule_generator
  delegate :fourth_draw_amount, to: :premium_schedule_generator
  delegate :fourth_draw_months, to: :premium_schedule_generator
  delegate :premium_rate, to: :premium_schedule_generator

  def initialize(quarter, total_quarters, premium_schedule_generator)
    @quarter                           = quarter
    @total_quarters                    = total_quarters
    @premium_schedule_generator                  = premium_schedule_generator
    @initial_capital_repayment_holiday = premium_schedule_generator.initial_capital_repayment_holiday.to_i
  end

  def premium_amount
    if quarter < total_quarters
      amount_in_pounds = aggregate_outstanding_amount.to_d
      premium_rate_per_quarter = premium_rate / 100 / 4

      BankersRoundingMoney.new((amount_in_pounds * 100) * premium_rate_per_quarter)
    else
      Money.new(0)
    end
  end

  private

  def aggregate_outstanding_amount
    first_draw_down_outstanding_balance(initial_draw_amount) +
      tranche_drawdown(:second) + tranche_drawdown(:third) + tranche_drawdown(:fourth)
  end

  # return the outstanding amount on the specified tranche draw down
  # if it has come into effect in this, or a previous, quarter
  def tranche_drawdown(tranche_number)
    draw_amount = send("#{tranche_number}_draw_amount")
    draw_month = send("#{tranche_number}_draw_months")

    # draw down doesn't exist
    if (draw_amount.nil? || draw_amount.zero?) && (draw_month.nil? || draw_month.zero?)
      return Money.new(0)
    end

    months_from_first_draw_until_repayment = get_months_from_first_draw_until_repayment(draw_month)
    remaining_months = repayment_duration - months_from_first_draw_until_repayment

    if months_from_first_draw_until_repayment <= last_month_in_quarter
      draw_amount - (draw_amount * (last_month_in_quarter - months_from_first_draw_until_repayment)) / remaining_months
    elsif draw_month <= last_month_in_quarter
      draw_amount
    else
      Money.new(0)
    end
  end

  def get_months_from_first_draw_until_repayment(draw_month)
    initial_capital_repayment_holiday <= draw_month ?  draw_month : initial_capital_repayment_holiday
  end

  # how much capital remains on the initial draw amount
  def first_draw_down_outstanding_balance(initial_draw_amount)
    # repayment holiday is complete, either in this or a previous quarter (may have ended mid-quarter e.g. month 5)
    if repayment_holiday_complete?
      remaining_months = repayment_duration - initial_capital_repayment_holiday
      initial_draw_amount - (initial_draw_amount * (last_month_in_quarter - initial_capital_repayment_holiday)) / remaining_months
    else
      # if in repayment holiday, no capital repaid yet
      if repayment_holiday_active?
        initial_draw_amount
      # some capital already repaid (unless first quarter)
      else
        initial_draw_amount - capital_repaid_to_date
      end
    end
  end

  def last_month_in_quarter
    3 * quarter
  end

  def capital_repaid_to_date
    (initial_draw_amount / total_quarters) * quarter
  end

  def repayment_holiday_complete?
    initial_capital_repayment_holiday < last_month_in_quarter
  end

  def repayment_holiday_active?
    initial_capital_repayment_holiday >= last_month_in_quarter
  end

end
