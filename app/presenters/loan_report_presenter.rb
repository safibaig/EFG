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
  ALLOWED_LOAN_TYPES = LoanTypes::ALL.freeze
  LOAN_TYPES_BY_ID = LoanTypes::ALL.index_by(&:id)

  format :facility_letter_start_date, with: QuickDateFormatter
  format :facility_letter_end_date, with: QuickDateFormatter
  format :created_at_start_date, with: QuickDateFormatter
  format :created_at_end_date, with: QuickDateFormatter
  format :last_modified_start_date, with: QuickDateFormatter
  format :last_modified_end_date, with: QuickDateFormatter

  validates_presence_of :lender_ids, :loan_types
  validates_numericality_of :created_by_id, allow_blank: true
  validate :loan_types_are_allowed
  validate :loan_states_are_allowed

  def initialize(user, attributes = {})
    @user = user
    super(attributes)

    unless has_loan_type_selection?
      self.loan_types = [LoanTypes::EFG.id]
    end
  end

  attr_reader :user

  # Report Accessors
  def report
    # We rely on this presenter being valid to goven the correct access to the
    # LoanReport model. The presenter should be valid before calling #report.
    raise Invalid.new(self) unless valid?

    LoanReport.new.tap do |report|
      report.states = self.states
      report.loan_types = self.loan_types
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
  attr_accessor :created_by_id
  attr_reader :lender_ids, :loan_types, :states

  def allowed_lenders
    user.lenders
  end

  def lender_ids=(lender_ids)
    @lender_ids = filter_blank_multi_select(lender_ids)
  end

  def loan_types=(type_ids)
    type_ids = filter_blank_multi_select(type_ids) || []
    @loan_types = type_ids.map {|id| LOAN_TYPES_BY_ID[id]}.compact
  end

  def states=(states)
    @states = filter_blank_multi_select(states)
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
  def loan_types_are_allowed
    if loan_types.present? && loan_types.any? { |type| !ALLOWED_LOAN_TYPES.include?(type) }
      errors.add(:loan_types, :inclusion)
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
