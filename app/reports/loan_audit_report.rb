require 'active_model/model'

class LoanAuditReport
  include ActiveModel::Model

  ALLOWED_LOAN_STATES = Loan::States.sort.freeze

  attr_accessor :state, :lender_id, :event_id

  def self.date_attribute(*attributes)
    attributes.each do |attribute|

      attr_reader attribute

      define_method("#{attribute}=") do |value|
        instance_variable_set "@#{attribute}", QuickDateFormatter.parse(value)
      end

    end
  end

  date_attribute :facility_letter_start_date, :facility_letter_end_date,
                 :created_at_start_date, :created_at_end_date,
                 :last_modified_start_date, :last_modified_end_date,
                 :audit_records_start_date, :audit_records_end_date

  def loans
    scope = Loan.select(
        [
          'loans.*',
          'loan_state_changes.event_id AS loan_state_change_event_id',
          'loan_state_changes.state AS loan_state_change_to_state',
          'loan_state_changes.modified_at AS loan_state_change_modified_at',
          'first_loan_change.date_of_change AS loan_initial_draw_date',
          '(SELECT username FROM users WHERE id = loans.created_by_id) AS loan_created_by',
          '(SELECT username FROM users WHERE id = loans.modified_by_id) AS loan_modified_by',
          '(SELECT username FROM users WHERE id = loan_state_changes.modified_by_id) AS loan_state_change_modified_by',
          '(SELECT organisation_reference_code FROM lenders WHERE id = loans.lender_id) AS lender_reference_code'
        ].join(', ')
      ).joins("RIGHT OUTER JOIN loan_state_changes ON loans.id = loan_state_changes.loan_id")
       .joins("LEFT JOIN loan_modifications AS first_loan_change ON loans.id = first_loan_change.loan_id AND first_loan_change.seq = 0")
       .where("loans.modified_by_legacy_id != 'migration'")

    scope = scope.where('loans.state = ?', state) if state.present?
    scope = scope.where('loans.lender_id = ?', lender_id) if lender_id.present?
    scope = scope.where('loan_state_changes.event_id = ?', event_id) if event_id.present?
    scope = scope.where('loans.created_at >= ?', created_at_start_date.beginning_of_day) if created_at_start_date.present?
    scope = scope.where('loans.created_at <= ?', created_at_end_date.end_of_day) if created_at_end_date.present?
    scope = scope.where('loans.last_modified_at >= ?', last_modified_start_date.beginning_of_day) if last_modified_start_date.present?
    scope = scope.where('loans.last_modified_at <= ?', last_modified_end_date.end_of_day) if last_modified_end_date.present?
    scope = scope.where('loan_state_changes.modified_at >= ?', audit_records_start_date.beginning_of_day) if audit_records_start_date.present?
    scope = scope.where('loan_state_changes.modified_at <= ?', audit_records_end_date.end_of_day) if audit_records_end_date.present?

    # Note: facility_letter_start_date/facility_letter_end_date actually queries initial draw date
    # and includes records that do not have an initial draw date
    scope = scope.where('(first_loan_change.date_of_change >= ? or first_loan_change.date_of_change IS NULL)',
                        facility_letter_start_date) if facility_letter_start_date.present?
    scope = scope.where('(first_loan_change.date_of_change <= ? or first_loan_change.date_of_change IS NULL)',
                        facility_letter_end_date) if facility_letter_end_date.present?

    scope.order("loans.reference, loan_state_changes.version")
  end

  def count
    @count ||= loans.count
  end

  def event_name
    event ? event.name : 'All'
  end

  private

  def event
    event_id.present? ? LoanEvent.find(event_id.to_i) : nil
  end

end
