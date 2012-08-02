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
    state
    loan_source
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

  validates_presence_of :allowed_lender_ids, :lender_ids

  validates_numericality_of :created_by_id, allow_blank: true

  validates_inclusion_of :state, in: ALLOWED_LOAN_STATES, allow_blank: true

  validates_inclusion_of :loan_source, in: ALLOWED_LOAN_SOURCES

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

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
    loans.count
  end

  def loans
    Loan.where(query_conditions)
  end

  def to_csv
    LoanCsvExport.new(loans).generate
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
      state: "state = ?",
      loan_source: "loan_source = ?",
      loan_scheme: "loan_scheme = ?",
      lender_ids: "lender_id IN (?)",
      created_by_id: "created_by_id = ?",
      facility_letter_start_date: "facility_letter_date >= ?",
      facility_letter_end_date: "facility_letter_date <= ?",
      created_at_start_date: "created_at >= ?",
      created_at_end_date: "created_at <= ?",
      last_modified_start_date: "updated_at >= ?",
      last_modified_end_date: "updated_at <= ?"
    }
  end

  def validate_lender_ids
    return if lender_ids.blank?

    disallowed_lender_ids = lender_ids.collect(&:to_i) - allowed_lender_ids.collect(&:to_i)
    unless disallowed_lender_ids.empty?
      raise LoanReport::LenderNotAllowed, "Access to loans for lender(s) with ID #{disallowed_lender_ids.join(',')} is forbidden for this report"
    end
  end

end
