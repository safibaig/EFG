require 'csv'
require 'active_model/model'

class LoanReport
  class LenderNotAllowed < ArgumentError; end
end

class LoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  ALLOWED_LOAN_SOURCES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ].freeze

  ALLOWED_LOAN_SCHEMES = [ Loan::EFG_SCHEME, Loan::SFLG_SCHEME ].freeze

  DATE_FIELDS = %w(
    facility_letter_start_date
    facility_letter_end_date
    created_at_start_date
    created_at_end_date
    last_modified_start_date
    last_modified_end_date
  ).freeze

  OTHER_FIELDS = %w(
    allowed_lender_ids
    states
    loan_sources
    loan_scheme
    lender_ids
    created_by_id
  ).freeze

  DATE_FIELDS.each do |field|
    attr_reader field

    define_method "#{field}=" do |value|
      instance_variable_set "@#{field}", QuickDateFormatter.parse(value)
    end
  end

  OTHER_FIELDS.each { |attr| attr_accessor attr }

  validates_presence_of :allowed_lender_ids, :lender_ids, :loan_sources, :states

  validates_numericality_of :created_by_id, allow_blank: true

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

  validate :loan_sources_are_allowed

  validate :loan_states_are_allowed

  def initialize(attributes = {})
    super
    validate_lender_ids
  end

  def attributes
    (DATE_FIELDS + OTHER_FIELDS).inject({}) do |memo, field|
      memo[field] = send(field)
      memo
    end
  end

  def count
    @count ||= loans.count
  end

  def loans
    Loan.where(query_conditions).select(select_options)
  end

  # filter out blank entry in array (added by multiple check_box form helper)
  def loan_sources=(sources)
    @loan_sources = filter_blank_multi_select(sources)
  end

  # filter out blank entry in array (added by multiple check_box form helper)
  def states=(states)
    @states = filter_blank_multi_select(states)
  end

  def lender_ids=(lender_ids)
    @lender_ids = filter_blank_multi_select(lender_ids)
  end

  private

  # return ActiveRecord query array
  # e.g. ["facility_letter_date >= ? AND loan_scheme = ?", Date Object, 'E']
  def query_conditions
    conditions = []
    values = []

    query_conditions_mapping.each do |field, condition|
      value = send(field)
      next if value.blank?
      conditions << condition
      values << value
    end

    [conditions.join(" AND "), *values]
  end

  def query_conditions_mapping
    {
      states: "state IN (?)",
      loan_sources: "loan_source IN (?)",
      loan_scheme: "loan_scheme = ?",
      lender_ids: "loans.lender_id IN (?)",
      created_by_id: "created_by_id = ?",
      facility_letter_start_date: "facility_letter_date >= ?",
      facility_letter_end_date: "facility_letter_date <= ?",
      created_at_start_date: "created_at >= ?",
      created_at_end_date: "created_at <= ?",
      last_modified_start_date: "updated_at >= ?",
      last_modified_end_date: "updated_at <= ?"
    }
  end

  def select_options
    [
      'loans.*',
      '(SELECT name FROM lending_limits WHERE id = loans.lending_limit_id) AS lending_limit_name',
      '(SELECT organisation_reference_code FROM lenders WHERE id = loans.lender_id) AS lender_organisation_reference_code',
      '(SELECT recovered_on FROM recoveries WHERE loan_id = loans.id ORDER BY recoveries.id DESC LIMIT 1) AS last_recovery_on',
      '(SELECT SUM(amount_due_to_dti) FROM recoveries WHERE loan_id = loans.id) AS total_recoveries',
      '(SELECT created_at FROM loan_realisations WHERE realised_loan_id = loans.id ORDER BY loan_realisations.id DESC LIMIT 1) AS last_realisation_at',
      '(SELECT SUM(realised_amount) FROM loan_realisations WHERE realised_loan_id = loans.id) AS total_loan_realisations',
      '(SELECT SUM(amount_drawn) FROM loan_changes WHERE loan_id = loans.id) AS total_amount_drawn',
      '(SELECT SUM(lump_sum_repayment) FROM loan_changes WHERE loan_id = loans.id) AS total_lump_sum_repayment'
    ].join(',')
  end

  def validate_lender_ids
    return if lender_ids.blank?

    disallowed_lender_ids = lender_ids.collect(&:to_i) - allowed_lender_ids.collect(&:to_i)
    unless disallowed_lender_ids.empty?
      raise LoanReport::LenderNotAllowed, "Access to loans for lender(s) with ID #{disallowed_lender_ids.join(',')} is forbidden for this report"
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

end
