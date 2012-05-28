class LoanEligibilityCheck
  include LoanPresenter

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
    loan.trading_date = QuickDateFormatter.parse(value)
  end
end
