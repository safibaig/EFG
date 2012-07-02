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
  NotDemanded = 'not_demanded'.freeze
  Demanded = 'demanded'.freeze
  AutoCancelled = 'auto_cancelled'.freeze
  Removed = 'removed'.freeze
  RepaidFromTransfer = 'repaid_from_transfer'.freeze
  AutoRemoved = 'auto_removed'.freeze
  Settled = 'settled'.freeze
  Realised = 'realised'.freeze
  Recovered = 'recovered'.freeze
  IncompleteLegacy = 'incomplete_legacy'.freeze
  CompleteLegacy = 'complete_legacy'.freeze

  States = [Rejected, Eligible, Cancelled, Incomplete, Completed, Offered,
    Guaranteed, LenderDemand, Repaid, NotDemanded, Demanded, AutoCancelled,
    Removed, RepaidFromTransfer, AutoRemoved, Settled,Realised, Recovered,
    IncompleteLegacy, CompleteLegacy].freeze

  belongs_to :lender
  belongs_to :loan_allocation
  has_one :state_aid_calculation

  scope :offered, where(:state => Offered)

  scope :demanded, where(:state => Demanded)

  scope :not_progressed, where(:state => [Loan::Eligible, Loan::Completed, Loan::Incomplete])

  scope :guaranteed, where(:state => Loan::Guaranteed)

  scope :last_updated_between, lambda { |start_date, end_date|
    where("updated_at >= ? AND updated_at <= ?", start_date, end_date)
  }

  scope :maturity_date_between, lambda { |start_date, end_date|
    where("maturity_date >= ? AND maturity_date <= ?", start_date, end_date)
  }

  scope :by_reference, lambda { |reference|
    where("reference LIKE ?", "%#{reference}%")
  }

  validates_inclusion_of :state, in: States, strict: true
  validates_presence_of :lender_id, strict: true

  format :amount, with: MoneyFormatter.new
  format :fees, with: MoneyFormatter.new
  format :initial_draw_value, with: MoneyFormatter.new
  format :turnover, with: MoneyFormatter.new
  format :outstanding_amount, with: MoneyFormatter.new
  format :repayment_duration, with: MonthDurationFormatter
  format :borrower_demanded_amount, with: MoneyFormatter.new
  format :cancelled_on, with: QuickDateFormatter
  format :borrower_demanded_on, with: QuickDateFormatter
  format :trading_date, with: QuickDateFormatter
  format :maturity_date, with: QuickDateFormatter
  format :initial_draw_date, with: QuickDateFormatter
  format :maturity_date, with: QuickDateFormatter
  format :facility_letter_date, with: QuickDateFormatter
  format :repaid_on, with: QuickDateFormatter
  format :no_claim_on, with: QuickDateFormatter
  format :dti_demanded_on, with: QuickDateFormatter
  format :dti_demand_outstanding, with: MoneyFormatter.new
  format :dti_amount_claimed, with: MoneyFormatter.new
  format :dti_interest, with: MoneyFormatter.new
  format :current_refinanced_value, with: MoneyFormatter.new
  format :final_refinanced_value, with: MoneyFormatter.new
  format :borrower_demand_outstanding, with: MoneyFormatter.new
  format :state_aid, with: MoneyFormatter.new('EUR')
  format :borrower_demanded_amount, with: MoneyFormatter.new
  format :overdraft_limit, with: MoneyFormatter.new
  format :invoice_discount_limit, with: MoneyFormatter.new
  format :remove_guarantee_outstanding_amount, with: MoneyFormatter.new

  def self.with_state(state)
    where(:state => state)
  end

  def cancelled_reason
    CancelReason.find(cancelled_reason_id)
  end

  def state_aid_value
    Money.new(0, 'EUR')
  end

  attr_writer :state_aid_value

  def has_state_aid_calculation?
    state_aid_calculation.present?
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

  def legal_form
    LegalForm.find(legal_form_id)
  end

  def eligibility_check
    EligibilityCheck.new(self)
  end

  def repayment_frequency
    RepaymentFrequency.find(repayment_frequency_id)
  end

  # TODO: implement SIC code description
  def sic_code_description
    "to-do"
  end

  # TODO: implement legacy system reference format
  def reference
    super || id
  end

  # TODO: !
  def created_by
    User.first
  end

  # TODO: !
  def modified_by
    User.first
  end
end
