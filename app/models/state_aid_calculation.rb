class StateAidCalculation < ActiveRecord::Base
  belongs_to :loan

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_draw_months, :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months

  validates_presence_of :loan_id
  validates_presence_of :initial_draw_year, :initial_draw_amount,
    :initial_draw_months

  def initial_draw_amount
    MoneyFormatter.format(super)
  end

  def initial_draw_amount=(value)
    super(MoneyFormatter.parse(value))
  end
end
