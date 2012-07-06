class StateAidCalculation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :loan, inverse_of: :state_aid_calculation

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

  # We believe these are defined in the relevant legislation?
  GUARANTEE_RATE = 0.75
  RISK_FACTOR = 0.3

  def premium_schedule
    PremiumSchedule.new(self)
  end

  def state_aid_gbp
    (initial_draw_amount * GUARANTEE_RATE * RISK_FACTOR) - premium_schedule.total_premiums
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
