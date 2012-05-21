require 'active_model/model'

class LoanEligibilityCheck
  include ActiveModel::Model

  ATTRIBUTES = [:viable_proposition, :would_you_lend, :collateral_exhausted,
                :lender_cap, :sic_code, :loan_category, :reason,
                :previous_borrowing, :private_residence_charge_required,
                :personal_guarantee_required]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, :trading_date, to: :loan

  attr_reader :loan

  def initialize(*)
    @loan = Loan.new
    super
  end

  def amount
    Money.new(loan.amount) if loan.amount
  end

  def amount=(value)
    loan.amount = Money.parse(value).cents
  end

  def repayment_duration
    MonthDuration.new(loan.repayment_duration)
  end

  def repayment_duration=(hash)
    loan.repayment_duration = MonthDuration.from_hash(hash).total_months
  end

  def trading_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.trading_date = Date.new(year, month, day)
  end

  def turnover
    Money.new(loan.turnover) if loan.turnover
  end

  def turnover=(value)
    loan.turnover = Money.parse(value).cents
  end
end
