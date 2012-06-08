class Loan < ActiveRecord::Base
  include FormatterConcern

  Rejected = 'rejected'.freeze
  Eligible = 'eligible'.freeze
  Cancelled = 'cancelled'.freeze
  Incomplete = 'incomplete'.freeze
  Completed = 'completed'.freeze
  Offered = 'offered'.freeze
  Guaranteed = 'guaranteed'.freeze
  LenderDemand = 'lender_demand'.freeze
  Repaid = 'repaid'.freeze

  States = [Rejected, Eligible, Cancelled, Incomplete, Completed, Offered,
    Guaranteed, LenderDemand, Repaid]

  belongs_to :lender
  has_one :state_aid_calculation

  validates_inclusion_of :state, in: States, strict: true
  validates_presence_of :lender, strict: true

  format :amount, with: MoneyFormatter
  format :fees, with: MoneyFormatter
  format :initial_draw_value, with: MoneyFormatter
  format :turnover, with: MoneyFormatter
  format :repayment_duration, with: MonthDurationFormatter
  format :borrower_demanded_amount, with: MoneyFormatter

  def self.with_state(state)
    where(:state => state)
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

  def interest_rate_type
    InterestRateType.find(interest_rate_type_id)
  end

  def eligibility_check
    EligibilityCheck.new(self)
  end
end
