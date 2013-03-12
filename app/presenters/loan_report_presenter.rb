require 'active_model/model'

class LoanReportPresenter
  class Invalid < RuntimeError
    def initialize(loan_report)
      @loan_report = loan_report
    end

    def message
      "#{super}: #{@loan_report.errors.full_messages.join(', ')}"
    end
  end

  include ActiveModel::Model
  include PresenterFormatterConcern

  def self.model_name
    ActiveModel::Name.new(self, nil, 'LoanReport')
  end

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  ALLOWED_LOAN_SOURCES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ].freeze

  ALLOWED_LOAN_SCHEMES = [ Loan::EFG_SCHEME, Loan::SFLG_SCHEME ].freeze

  attr_accessor :created_by_id, :loan_scheme
  attr_reader :lender_ids, :loan_sources, :states

  format :facility_letter_start_date, with: QuickDateFormatter
  format :facility_letter_end_date, with: QuickDateFormatter
  format :created_at_start_date, with: QuickDateFormatter
  format :created_at_end_date, with: QuickDateFormatter
  format :last_modified_start_date, with: QuickDateFormatter
  format :last_modified_end_date, with: QuickDateFormatter

  validates_presence_of :lender_ids, :loan_sources

  validates_numericality_of :created_by_id, allow_blank: true

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

  validate :loan_sources_are_allowed

  validate :loan_states_are_allowed

  def initialize(user, attributes = {})
    @user = user
    super(attributes)
  end

  attr_reader :user

  # Report Accessors
  def report
    # We rely on this presenter being valid to goven the correct access to the
    # LoanReport model. The presenter should be valid before calling #report.
    raise Invalid.new(self) unless valid?

    LoanReport.new.tap do |report|
      report.states = self.states
      report.loan_sources = self.loan_sources
      report.loan_scheme = self.loan_scheme
      report.lender_ids = filter_lender_ids(self.lender_ids)
      report.created_by_id = self.created_by_id
      report.facility_letter_start_date = self.facility_letter_start_date
      report.facility_letter_end_date = self.facility_letter_end_date
      report.created_at_start_date = self.created_at_start_date
      report.created_at_end_date = self.created_at_end_date
      report.last_modified_start_date = self.last_modified_start_date
      report.last_modified_end_date = self.last_modified_end_date
    end
  end

  def loans
    report.loans
  end

  def count
    report.count
  end

  # Form Attributes
  def allowed_lenders
    user.lenders
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

  # Permissions
  def has_lender_selection?
    !user.lender.is_a?(Lender)
  end

  def has_loan_type_selection?
    user.lender.can_access_all_loan_schemes?
  end

  def has_created_by_selection?
    user.lender.is_a?(Lender)
  end

  private
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

  # User's that can choose a lender are restricted to lender's they can access.
  # User's that can't choose a lender have it set to their list of lenders.
  def filter_lender_ids(lender_ids)
    if has_lender_selection? && lender_ids.present?
      user.lender_ids & lender_ids.map(&:to_i)
    else
      user.lender_ids
    end
  end
end
