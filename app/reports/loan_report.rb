require 'active_model/model'

class LoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  ALLOWED_LOAN_SOURCES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ].freeze

  ALLOWED_LOAN_SCHEMES = [ Loan::EFG_SCHEME, Loan::SFLG_SCHEME ].freeze

  attr_accessor :facility_letter_start_date, :facility_letter_end_date,
                :created_at_start_date, :created_at_end_date,
                :last_modified_start_date, :last_modified_end_date,
                :state, :loan_source, :loan_scheme, :lender_ids

  # TODO: implement created_by user for loans so report can filter by that user

  # attr_accessor :created_by_user_id

  # validates_presence_of :created_by_user_id

  validates_presence_of :lender_ids

  validates_inclusion_of :state, in: ALLOWED_LOAN_STATES, allow_blank: true

  validates_inclusion_of :loan_source, in: ALLOWED_LOAN_SOURCES

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES, allow_blank: true

  %w(
    facility_letter_start_date
    facility_letter_end_date
    created_at_start_date
    created_at_end_date
    last_modified_start_date
    last_modified_end_date
  ).each do |field|
     validates_format_of field, with: %r{(\d){2}/(\d){2}/(\d){4}}, allow_nil: true, allow_blank: true
  end

  def initialize(attributes = {})
    super
    @attributes = attributes
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

    @attributes.each_pair do |key, value|
      next if value.blank?

      if date_field_mapping.has_key?(key)
        conditions << date_field_mapping[key]
        values << Date.parse(value)
      elsif key.to_sym == :lender_ids
        conditions << "lender_id IN (?)"
        values << value
      else
        conditions << "#{key} = ?"
        values << value
      end
    end

    [conditions.join(" AND "), *values]
  end

  def date_field_mapping
    HashWithIndifferentAccess.new(
      facility_letter_start_date: "facility_letter_date >= ?",
      facility_letter_end_date: "facility_letter_date <= ?",
      created_at_start_date: "created_at >= ?",
      created_at_end_date: "created_at <= ?",
      last_modified_start_date: "updated_at >= ?",
      last_modified_end_date: "updated_at <= ?"
    )
  end

end
