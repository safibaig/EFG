class Loan < ActiveRecord::Base
  validates_presence_of :amount, :lender_cap,
    :turnover, :trading_date, :sic_code, :loan_category, :reason
  validates_inclusion_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :previous_borrowing,
    :private_residence_charge_required, :personal_guarantee_required, in: [true, false]
  validates_numericality_of :repayment_duration, greater_than: 0, only_integer: true
end
