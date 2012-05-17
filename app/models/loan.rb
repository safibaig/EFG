class Loan < ActiveRecord::Base
  validates_presence_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :amount, :lender_cap, :repayment_duration,
    :turnover, :trading_date, :sic_code, :loan_category, :reason,
    :previous_borrowing, :private_residence_charge_required,
    :personal_guarantee_required
end
