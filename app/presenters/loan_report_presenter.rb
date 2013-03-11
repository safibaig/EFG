require 'active_model/model'

class LoanReportPresenter
  class LenderNotAllowed < ArgumentError; end

  include ActiveModel::Model
  include PresenterFormatterConcern

  def self.model_name
    ActiveModel::Name.new(self, nil, 'LoanReport')
  end

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  ALLOWED_LOAN_SOURCES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ].freeze

  ALLOWED_LOAN_SCHEMES = [ Loan::EFG_SCHEME, Loan::SFLG_SCHEME ].freeze

  attr_accessor :allowed_lender_ids, :states, :loan_sources, :loan_scheme, :lender_ids, :created_by_id

  format :facility_letter_start_date, with: QuickDateFormatter
  format :facility_letter_end_date, with: QuickDateFormatter
  format :created_at_start_date, with: QuickDateFormatter
  format :created_at_end_date, with: QuickDateFormatter
  format :last_modified_start_date, with: QuickDateFormatter
  format :last_modified_end_date, with: QuickDateFormatter

  validates_presence_of :allowed_lender_ids, :lender_ids, :loan_sources

  validates_numericality_of :created_by_id, allow_blank: true

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

  validate :lender_ids_are_allowed

  validate :loan_sources_are_allowed

  validate :loan_states_are_allowed

  def loans
    report.loans
  end

  def count
    report.count
  end

  def loan_sources=(sources)
    @loan_sources = filter_blank_multi_select(sources)
  end

  def states=(states)
    @states = filter_blank_multi_select(states)
  end

  def lender_ids=(lender_ids)
    @lender_ids = filter_blank_multi_select(lender_ids)
  end

  private

  def lender_ids_are_allowed
    return if lender_ids.blank?

    disallowed_lender_ids = lender_ids.collect(&:to_i) - allowed_lender_ids.collect(&:to_i)
    unless disallowed_lender_ids.empty?
      raise LenderNotAllowed, "Access to loans for lender(s) with ID #{disallowed_lender_ids.join(',')} is forbidden for this report"
    end
  end

  def loan_sources_are_allowed
    if loan_sources.present? && loan_sources.any? { |source| !ALLOWED_LOAN_SOURCES.include?(source) }
      errors.add(:loan_sources, :inclusion)
    end
  end

  def loan_states_are_allowed
    if states.present? && states.any? { |state| !ALLOWED_LOAN_STATES.include?(state) }
      errors.add(:states, :inclusion)
    end
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_select(values)
    values.is_a?(Array) ? values.reject(&:blank?) : values
  end

  def report
    LoanReport.new.tap do |report|
      report.states = self.states
      report.loan_sources = self.loan_sources
      report.loan_scheme = self.loan_scheme
      report.lender_ids = self.lender_ids
      report.created_by_id = self.created_by_id
      report.facility_letter_start_date = self.facility_letter_start_date
      report.facility_letter_end_date = self.facility_letter_end_date
      report.created_at_start_date = self.created_at_start_date
      report.created_at_end_date = self.created_at_end_date
      report.last_modified_start_date = self.last_modified_start_date
      report.last_modified_end_date = self.last_modified_end_date
    end
  end
end
