require 'csv'

class LoanAuditReportCsvExport

  include Enumerable

  def initialize(loans_scope)
    @loans_scope = loans_scope
    unless loans_scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, "Expected loans_scope to be instance of ActiveRecord::Relation"
    end
  end

  def header
    %w(
      loan_reference
      lender_id
      facility_amount
      maturity_date
      cancellation_date
      scheme_facility_letter_date
      initial_draw_date
      lender_demand_date
      repaid_date
      no_claim_date
      government_demand_date
      settled_date
      guarantee_remove_date
      generic1
      generic2
      generic3
      generic4
      generic5
      loan_reason
      loan_category
      loan_state
      created_at
      created_by
      modified_date
      modified_by
      audit_record_sequence
      from_state
      to_state
      loan_function
      audit_record_modified_date
      audit_record_modified_by
    ).collect { |field| t(field) }
  end

  def generate
    enumerator.to_a.join
  end

  def enumerator
    Enumerator.new do |y|
      previous_state = nil
      previous_loan_id = nil
      sequence = 0

      y << CSV.generate_line(header)

      @loans_scope.find_each do |loan|
        if previous_loan_id != loan.id
          previous_state = nil
          sequence = 0
        end

        y << CSV.generate_line(LoanAuditReportCsvRow.new(loan, sequence, previous_state).row)

        sequence += 1
        previous_state = loan.loan_state_change_to_state
        previous_loan_id = loan.id
      end
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_audit_report')
  end

end
