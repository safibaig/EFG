require 'active_model/model'

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
  )

  OTHER_FIELDS = %w(
    state
    loan_source
    loan_scheme
    lender_ids
  )

  DATE_FIELDS.each do |field|
    attr_reader field

    define_method "#{field}=" do |value|
      instance_variable_set "@#{field}", QuickDateFormatter.parse(value)
    end
  end

  OTHER_FIELDS.each { |attr| attr_accessor attr }

  # TODO: implement created_by user for loans so report can filter by that user

  # attr_accessor :created_by_user_id

  # validates_presence_of :created_by_user_id

  validates_presence_of :lender_ids

  validates_inclusion_of :state, in: ALLOWED_LOAN_STATES, allow_blank: true

  validates_inclusion_of :loan_source, in: ALLOWED_LOAN_SOURCES

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

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

    attributes.each_pair do |key, value|
      next if value.blank?
      conditions << query_conditions_mapping[key.to_sym]
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
      facility_letter_start_date: "facility_letter_date >= ?",
      facility_letter_end_date: "facility_letter_date <= ?",
      created_at_start_date: "created_at >= ?",
      created_at_end_date: "created_at <= ?",
      last_modified_start_date: "updated_at >= ?",
      last_modified_end_date: "updated_at <= ?"
    }
  end

end
