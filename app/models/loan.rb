require 'loan_reference'
require 'legacy_loan_reference'

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
    Removed, RepaidFromTransfer, AutoRemoved, Settled, Realised, Recovered,
    IncompleteLegacy, CompleteLegacy].freeze

  # All new loans are in the EFG scheme
  EFG_SCHEME = 'E'
  SFLG_SCHEME = 'S'

  # All new loans have SFLG source
  SFLG_SOURCE = 'S'
  LEGACY_SFLG_SOURCE = 'L'

  belongs_to :lender
  belongs_to :lending_limit
  belongs_to :created_by, class_name: 'User'
  belongs_to :modified_by, class_name: 'User'
  belongs_to :invoice
  belongs_to :ded_code, foreign_key: 'dti_ded_code', primary_key: 'code'
  has_many :state_aid_calculations, inverse_of: :loan, order: :seq
  has_one :initial_draw_change
  has_one :transferred_from, class_name: 'Loan', foreign_key: 'id', primary_key: 'transferred_from_id'
  has_many :data_corrections
  has_many :demand_to_borrowers
  has_many :loan_changes
  has_many :loan_modifications
  has_many :loan_realisations, foreign_key: 'realised_loan_id'
  has_many :recoveries
  has_many :loan_securities
  has_many :ineligibility_reasons, class_name: 'LoanIneligibilityReason'
  has_many :state_changes, class_name: 'LoanStateChange', order: :modified_at

  scope :offered,         where(state: Loan::Offered)
  scope :demanded,        where(state: Loan::Demanded)
  scope :lender_demanded, where(state: Loan::LenderDemand)
  scope :not_progressed,  where(state: [Loan::Eligible, Loan::Completed, Loan::Incomplete])
  scope :guaranteed,      where(state: Loan::Guaranteed)
  scope :recovered,       where(state: Loan::Recovered)

  scope :changeable,  where(state: [Loan::Guaranteed, Loan::LenderDemand])
  scope :correctable, where(state: [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded])
  scope :recoverable, where(state: [Loan::Settled, Loan::Recovered, Loan::Realised])

  scope :last_updated_between, lambda { |start_date, end_date|
    where("updated_at >= ? AND updated_at <= ?", start_date.to_time, end_date.to_time)
  }

  scope :maturity_date_between, lambda { |start_date, end_date|
    where("maturity_date >= ? AND maturity_date <= ?", start_date, end_date)
  }

  scope :facility_letter_date_between, lambda { |start_date, end_date|
    where("facility_letter_date >= ? AND facility_letter_date <= ?", start_date, end_date)
  }

  scope :borrower_demanded_date_between, lambda { |start_date, end_date|
    where("borrower_demanded_on >= ? AND borrower_demanded_on <= ?", start_date, end_date)
  }

  scope :by_reference, lambda { |reference|
    where("reference LIKE ?", "%#{reference}%")
  }

  validates_inclusion_of :state, in: States, strict: true
  validates_presence_of :lender_id, strict: true
  validates_presence_of :created_by, strict: true
  validates_presence_of :modified_by, strict: true

  format :amount, with: MoneyFormatter.new
  format :fees, with: MoneyFormatter.new
  format :turnover, with: MoneyFormatter.new
  format :outstanding_amount, with: MoneyFormatter.new
  format :repayment_duration, with: MonthDurationFormatter
  format :amount_demanded, with: MoneyFormatter.new
  format :cancelled_on, with: QuickDateFormatter
  format :borrower_demanded_on, with: QuickDateFormatter
  format :trading_date, with: QuickDateFormatter
  format :maturity_date, with: QuickDateFormatter
  format :facility_letter_date, with: QuickDateFormatter
  format :repaid_on, with: QuickDateFormatter
  format :no_claim_on, with: QuickDateFormatter
  format :dti_demanded_on, with: QuickDateFormatter
  format :remove_guarantee_on, with: QuickDateFormatter
  format :dti_demand_outstanding, with: MoneyFormatter.new
  format :dti_amount_claimed, with: MoneyFormatter.new
  format :dti_interest, with: MoneyFormatter.new
  format :dti_break_costs, with: MoneyFormatter.new
  format :current_refinanced_amount, with: MoneyFormatter.new
  format :final_refinanced_amount, with: MoneyFormatter.new
  format :borrower_demand_outstanding, with: MoneyFormatter.new
  format :state_aid, with: MoneyFormatter.new('EUR')
  format :overdraft_limit, with: MoneyFormatter.new
  format :invoice_discount_limit, with: MoneyFormatter.new
  format :remove_guarantee_outstanding_amount, with: MoneyFormatter.new
  format :recovery_on, with: QuickDateFormatter

  before_create :set_reference

  def self.with_scheme(scheme)
    case scheme
    when 'efg'
      where(loan_scheme: EFG_SCHEME)
    when 'sflg'
      where(loan_scheme: SFLG_SCHEME, loan_source: SFLG_SOURCE)
    when 'legacy_sflg'
      where(loan_scheme: SFLG_SCHEME, loan_source: LEGACY_SFLG_SOURCE)
    when 'non_efg'
      where(loan_scheme: SFLG_SCHEME, loan_source: [SFLG_SOURCE, LEGACY_SFLG_SOURCE])
    else
      none
    end
  end

  def self.with_state(state)
    where(state: state)
  end

  def cancelled_reason
    CancelReason.find(cancelled_reason_id)
  end

  def cumulative_drawn_amount
    Money.new(loan_modifications.sum(:amount_drawn))
  end

  def cumulative_lump_sum_amount
    Money.new(loan_changes.sum(:lump_sum_repayment))
  end

  def cumulative_recoveries_amount
    Money.new(recoveries.sum(:amount_due_to_dti))
  end

  def cumulative_realised_amount
    Money.new(loan_realisations.sum(:realised_amount))
  end

  def cumulative_unrealised_recoveries_amount
    cumulative_recoveries_amount - cumulative_realised_amount
  end

  def last_realisation_amount
    loan_realisations.present? ? loan_realisations.last.realised_amount : Money.new(0)
  end

  def amount_not_yet_drawn
    amount - cumulative_drawn_amount
  end

  def state_aid_calculation
    state_aid_calculations.last
  end

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

  def loan_security_types
    loan_securities.collect { |security| security.loan_security_type }
  end

  def loan_security_types=(security_type_ids)
    loan_securities.clear
    security_type_ids.reject(&:blank?).each do |id|
      loan_securities.build(loan_security_type_id: id)
    end
  end

  def cumulative_total_previous_recoveries
    @cumulative_total_previous_recoveries ||= Money.new(recoveries.sum(:amount_due_to_dti))
  end

  def premium_schedule
    return nil unless self.state_aid_calculation
    PremiumSchedule.new(self.state_aid_calculation, self)
  end

  def already_transferred?
    return false if reference.blank?
    next_loan_reference = reference_class.new(reference).increment
    Loan.exists?(reference: next_loan_reference)
  end

  def created_from_transfer?
    return false if reference.blank?
    reference[-2,2].to_i > 1
  end

  def efg_loan?
    loan_source == SFLG_SOURCE && loan_scheme == EFG_SCHEME
  end

  def legacy_loan?
    loan_source == LEGACY_SFLG_SOURCE
  end

  def guarantee_rate
    read_attribute(:guarantee_rate) || lending_limit && lending_limit.guarantee_rate
  end

  def premium_rate
    read_attribute(:premium_rate) || lending_limit && lending_limit.premium_rate
  end

  def sflg?
    loan_source == SFLG_SOURCE && loan_scheme == SFLG_SCHEME
  end

  def state_history
    @state_history ||= (state_changes.pluck(:state) << state).uniq
  end

  def update_state!(to_state, event, modified_by_user)
    self.class.transaction do
      self.update_attribute(:state, to_state)
      LoanStateChange.log(self, event, modified_by_user)
    end
  end

  def corrected?
    self.data_corrections.count > 0
  end

  def calculate_dti_amount_claimed
    interest           = self.dti_interest || Money.new(0)
    break_costs        = self.dti_break_costs || Money.new(0)
    demand_outstanding = self.dti_demand_outstanding || Money.new(0)

    if self.efg_loan?
      self.dti_amount_claimed = demand_outstanding * self.guarantee_rate / 100
    else
      self.dti_amount_claimed = (demand_outstanding + interest + break_costs) * self.guarantee_rate / 100
    end
  end

  private

  def set_reference
    unless reference.present?
      reference_string = LoanReference.generate
      self.reference = self.class.exists?(reference: reference_string) ? set_reference : reference_string
    end
  end

  def reference_class
    legacy_loan? ? LegacyLoanReference : LoanReference
  end

end
