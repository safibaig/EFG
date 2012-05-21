require 'active_model/model'

class LoanEligibilityCheck
  include ActiveModel::Model

  ATTRIBUTES = [:viable_proposition, :would_you_lend, :collateral_exhausted,
                :lender_cap_id, :sic_code, :loan_category_id, :reason_id,
                :previous_borrowing, :private_residence_charge_required,
                :personal_guarantee_required, :amount, :turnover,
                :repayment_duration]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, :trading_date, to: :loan

  attr_reader :loan

  def initialize(*)
    @loan = Loan.new
    super
  end

  def trading_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.trading_date = Date.new(year, month, day)
  end
end
