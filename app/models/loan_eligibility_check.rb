class LoanEligibilityCheck
  include LoanStateTransition

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :lender_cap_id
  attribute :sic_code
  attribute :loan_category_id
  attribute :reason_id
  attribute :previous_borrowing
  attribute :private_residence_charge_required
  attribute :personal_guarantee_required
  attribute :amount
  attribute :turnover
  attribute :repayment_duration
  attribute :trading_date

  def trading_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.trading_date = Date.new(year, month, day)
  end
end
