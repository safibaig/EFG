class StateAidCalculation < ActiveRecord::Base
  include FormatterConcern

  SCHEDULE_TYPE = 'S'.freeze
  RESCHEDULE_TYPE = 'R'.freeze
  NOTIFIED_AID_TYPE = 'N'.freeze
  MAX_INITIAL_DRAW = Money.new(9_999_999_99)

  belongs_to :loan, inverse_of: :state_aid_calculations

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_draw_months, :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months,
    :loan_id, :premium_cheque_month

  before_validation :set_seq, on: :create

  validates_presence_of :loan_id
  validates_presence_of :initial_draw_months
  validates_inclusion_of :calc_type, in: [ SCHEDULE_TYPE, RESCHEDULE_TYPE, NOTIFIED_AID_TYPE ]
  validates_presence_of :initial_draw_year, unless: :reschedule?
  validates_format_of :premium_cheque_month, with: /\A\d{2}\/\d{4}\z/, if: :reschedule?, message: :invalid_format

  validate :premium_cheque_month_in_the_future, if: :reschedule?
  validate :initial_draw_amount_is_within_limit

  format :initial_draw_amount, with: MoneyFormatter.new
  format :second_draw_amount, with: MoneyFormatter.new
  format :third_draw_amount, with: MoneyFormatter.new
  format :fourth_draw_amount, with: MoneyFormatter.new

  # TODO: Confirm this value is correct for all loans
  RISK_FACTOR = 0.3

  def premium_schedule
    PremiumSchedule.new(self, loan)
  end

  def state_aid_gbp
    (loan.amount * (loan.guarantee_rate / 100) * RISK_FACTOR) - premium_schedule.total_premiums
  end

  def state_aid_eur
    euro = state_aid_gbp * 1.1974
    Money.new(euro.cents, 'EUR')
  end

  after_save do |calculation|
    calculation.loan.update_attribute :state_aid, state_aid_eur
  end

  def reschedule?
    calc_type == RESCHEDULE_TYPE
  end

  private
    def set_seq
      self.seq = (StateAidCalculation.where(loan_id: loan_id).maximum(:seq) || -1) + 1 unless seq
    end

    def initial_draw_amount_is_within_limit
      if initial_draw_amount.blank? || initial_draw_amount < 0 || initial_draw_amount > MAX_INITIAL_DRAW
        errors.add(:initial_draw_amount, :invalid)
      end
    end

    def premium_cheque_month_in_the_future
      begin
        date = Date.parse("01/#{premium_cheque_month}")
      rescue ArgumentError
        errors.add(:premium_cheque_month, :invalid_format)
        return
      end

      errors.add(:premium_cheque_month, :invalid) unless date > Date.today.end_of_month
    end
end
