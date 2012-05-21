class Loan < ActiveRecord::Base
  validates_presence_of :amount, :lender_cap_id,
    :turnover, :trading_date, :sic_code, :loan_category_id, :reason_id
  validates_inclusion_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :previous_borrowing,
    :private_residence_charge_required, :personal_guarantee_required, in: [true, false]
  validates_numericality_of :repayment_duration, greater_than: 0, only_integer: true
  validates_numericality_of :amount, greater_than: 0, only_integer: true

  def amount
    value = read_attribute(:amount)
    Money.new(value) if value
  end

  def amount=(value)
    cents = value.blank? ? nil : Money.parse(value).cents
    write_attribute(:amount, cents)
  end

  def lender_cap
    LoanFacility.find(lender_cap_id)
  end

  def loan_category
    LoanCategory.find(loan_category_id)
  end

  def reason
    LoanReason.find(reason_id)
  end

  def turnover
    value = read_attribute(:turnover)
    Money.new(value) if value
  end

  def turnover=(value)
    cents = value.blank? ? nil : Money.parse(value).cents
    write_attribute(:turnover, cents)
  end
end
