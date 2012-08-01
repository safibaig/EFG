require 'active_model/model'

class LoanReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = (Loan::States + ['All']).sort

  ALLOWED_LOAN_TYPES = [ Loan::SFLG_SOURCE, Loan::LEGACY_SFLG_SOURCE ]

  ALLOWED_LOAN_SCHEMES = [ "All", Loan::EFG_SCHEME, Loan::SFLG_SCHEME ]

  attr_accessor :facility_letter_start_date, :facility_letter_end_date,
                :created_at_start_date, :created_at_end_date,
                :last_modified_start_date, :last_modified_end_date,
                :state, :loan_source, :loan_scheme, :lender_id

  # TODO: implement created_by user for loans so report can filter by that user

  # attr_accessor :created_by_user_id

  # validates_presence_of :created_by_user_id

  validates_presence_of :lender_id

  validates_inclusion_of :state, in: ALLOWED_LOAN_STATES

  validates_inclusion_of :loan_source, in: ALLOWED_LOAN_TYPES

  validates_inclusion_of :loan_scheme, in: ALLOWED_LOAN_SCHEMES

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

  private

  # return ActiveRecord query array
  # e.g. ["facility_letter_date >= ? AND loan_scheme = ?", Date Object, 'E']
  def query_conditions
    conditions = []
    values = []

    @attributes.each_pair do |key, value|
      next if value.blank? || value == 'All'

      if date_field_mapping.has_key?(key)
        conditions << date_field_mapping[key]
        values << Date.parse(value)
      else
        conditions << "#{key} = ?"
        values << value
      end
    end

    [conditions.join(" AND "), *values]
  end

  def date_field_mapping
    {
      facility_letter_start_date: "facility_letter_date >= ?",
      facility_letter_end_date: "facility_letter_date <= ?",
      created_at_start_date: "created_at >= ?",
      created_at_end_date: "created_at <= ?",
      last_modified_start_date: "updated_at >= ?",
      last_modified_end_date: "updated_at <= ?"
    }
  end

end
