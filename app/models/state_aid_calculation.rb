class StateAidCalculation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :loan

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_draw_months, :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months

  validates_presence_of :loan_id
  validates_presence_of :initial_draw_year, :initial_draw_amount,
    :initial_draw_months

  format :initial_draw_amount, with: MoneyFormatter.new
  format :second_draw_amount, with: MoneyFormatter.new
  format :third_draw_amount, with: MoneyFormatter.new
  format :fourth_draw_amount, with: MoneyFormatter.new

  GUARANTEE_RATE = 0.75
  RISK_FACTOR = 0.3
  PREMIUM_RATE = 0.02

  def premiums
    amount = initial_draw_amount
    quarters = initial_draw_months / 3

    (0..quarters).inject([]) do |memo, quarter|
      outstanding_capital = amount - ((amount / quarters) * quarter)
      memo[quarter] = outstanding_capital * PREMIUM_RATE / 4
      memo
    end
  end

  def total_premiums
    premiums.sum
  end

  def state_aid_gbp
    (initial_draw_amount * GUARANTEE_RATE * RISK_FACTOR) - total_premiums
  end

  def state_aid_eur
    euro = state_aid_gbp * 1.1974
    Money.new(euro.cents, 'EUR')
  end

  after_save do |calculation|
    calculation.loan.state_aid = state_aid_eur
    calculation.loan.save
  end
end
