class StateAidCalculation < ActiveRecord::Base
  include FormatterConcern

  attr_accessor :rescheduling

  belongs_to :loan, inverse_of: :state_aid_calculations

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_draw_months, :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months,
    :loan_id, :premium_cheque_month, :rescheduling

  before_validation :set_seq, on: :create

  validates_presence_of :loan_id

  validates_presence_of :initial_draw_months

  validates_presence_of :initial_draw_year, unless: :rescheduling

  validates_presence_of :premium_cheque_month, if: :rescheduling

  validate do
    if initial_draw_amount.blank? || initial_draw_amount < 0 || initial_draw_amount > Money.new(9_999_999_99)
      errors.add(:initial_draw_amount, :invalid)
    end

    if rescheduling
      errors.add(:premium_cheque_month, :invalid) unless premium_cheque_month_in_the_future?
    end
  end

  format :initial_draw_amount, with: MoneyFormatter.new
  format :second_draw_amount, with: MoneyFormatter.new
  format :third_draw_amount, with: MoneyFormatter.new
  format :fourth_draw_amount, with: MoneyFormatter.new

  # We believe these are defined in the relevant legislation?
  GUARANTEE_RATE = 0.75
  RISK_FACTOR = 0.3

  def premium_schedule
    PremiumSchedule.new(self, loan)
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

  private
    def set_seq
      self.seq = (StateAidCalculation.where(loan_id: loan_id).maximum(:seq) || -1) + 1 unless seq
    end

    def premium_cheque_month_in_the_future?
      cheque_date = Date.parse("01/#{premium_cheque_month}")
      today = Date.today
      cheque_date.month > today.month && cheque_date.year >= today.year
    end
end
