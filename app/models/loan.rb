class Loan < ActiveRecord::Base
  Eligible = 'eligible'.freeze
  Completed = 'completed'.freeze
  Offered = 'offered'.freeze
  Guaranteed = 'guaranteed'.freeze

  States = [Eligible, Completed, Offered, Guaranteed]

  belongs_to :lender

  validates_inclusion_of :state, in: States, strict: true
  validates_presence_of :lender, strict: true

  def lender_cap
    LoanFacility.find(lender_cap_id)
  end

  def loan_category
    LoanCategory.find(loan_category_id)
  end

  def reason
    LoanReason.find(reason_id)
  end

  def interest_rate_type
    InterestRateType.find(interest_rate_type_id)
  end

  def repayment_duration
    MonthDurationFormatter.format(read_attribute(:repayment_duration))
  end

  def repayment_duration=(hash)
    write_attribute(:repayment_duration, MonthDurationFormatter.parse(hash))
  end

  def amount
    MoneyFormatter.format(read_attribute(:amount))
  end

  def amount=(value)
    write_attribute(:amount, MoneyFormatter.parse(value))
  end

  def initial_draw_value
    MoneyFormatter.format(read_attribute(:initial_draw_value))
  end

  def initial_draw_value=(value)
    write_attribute(:initial_draw_value, MoneyFormatter.parse(value))
  end

  def turnover
    MoneyFormatter.format(read_attribute(:turnover))
  end

  def turnover=(value)
    write_attribute(:turnover, MoneyFormatter.parse(value))
  end

  def fees
    MoneyFormatter.format(read_attribute(:fees))
  end

  def fees=(value)
    write_attribute(:fees, MoneyFormatter.parse(value))
  end
end
