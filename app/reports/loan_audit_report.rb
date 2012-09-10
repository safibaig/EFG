require 'csv'
require 'active_model/model'

class LoanAuditReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  DATE_FIELDS = %w(
    facility_letter_start_date
    facility_letter_end_date
    created_at_start_date
    created_at_end_date
    last_modified_start_date
    last_modified_end_date
    audit_records_start_date
    audit_records_end_date
  ).freeze

  OTHER_FIELDS = %w(
    state
    lender_id
    event_id
  ).freeze

  DATE_FIELDS.each do |field|
    attr_reader field

    define_method "#{field}=" do |value|
      instance_variable_set "@#{field}", QuickDateFormatter.parse(value)
    end
  end

  OTHER_FIELDS.each { |attr| attr_accessor attr }

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
    Loan.
      select(select_options).
      joins("RIGHT OUTER JOIN loan_state_changes ON loans.id = loan_state_changes.loan_id").
      where("loans.modified_by_legacy_id != 'migration'").
      where(query_conditions).
      order("loans.reference, loan_state_changes.version")
  end

  private

  # return ActiveRecord query array
  # e.g. ["loans.facility_letter_date >= ? AND loans.state = ?", Date Object, 'Guaranteed']
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
      state: "loans.state = ?",
      lender_id: "loans.lender_id = ?",
      event_id: "loan_state_changes.event_id = ?",
      facility_letter_start_date: "loans.facility_letter_date >= ?",
      facility_letter_end_date: "loans.facility_letter_date <= ?",
      created_at_start_date: "loans.created_at >= ?",
      created_at_end_date: "loans.created_at <= ?",
      last_modified_start_date: "loans.updated_at >= ?",
      last_modified_end_date: "loans.updated_at <= ?",
      audit_records_start_date: "loan_state_changes.modified_on >= ?",
      audit_records_end_date: "loan_state_changes.modified_on <= ?"
    }
  end

  # TODO: update to take initial_draw_value from first loan change record
  def select_options
    [
      'loans.*',
      'loan_state_changes.event_id AS loan_state_change_event_id',
      'loan_state_changes.state AS loan_state_change_to_state',
      'loan_state_changes.modified_on AS loan_state_change_modified_on',
      '(SELECT username FROM users WHERE id = loans.created_by_id) AS loan_created_by',
      '(SELECT username FROM users WHERE id = loans.modified_by_id) AS loan_modified_by',
      '(SELECT username FROM users WHERE id = loan_state_changes.modified_by_id) AS loan_state_change_modified_by',
      '(SELECT organisation_reference_code FROM lenders WHERE id = loans.lender_id) AS lender_reference_code',
    ].join(',')
  end

end
