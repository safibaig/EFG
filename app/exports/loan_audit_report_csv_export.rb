class LoanAuditReportCsvExport < BaseCsvExport
  def self.translation_scope
    'csv_headers.loan_audit_report'
  end

  def fields
    [
      :loan_reference,
      :lender_id,
      :facility_amount,
      :maturity_date,
      :cancellation_date,
      :scheme_facility_letter_date,
      :initial_draw_date,
      :lender_demand_date,
      :repaid_date,
      :no_claim_date,
      :government_demand_date,
      :settled_date,
      :guarantee_remove_date,
      :generic1,
      :generic2,
      :generic3,
      :generic4,
      :generic5,
      :loan_reason,
      :loan_category,
      :loan_state,
      :created_at,
      :created_by,
      :modified_date,
      :modified_by,
      :audit_record_sequence,
      :from_state,
      :to_state,
      :loan_function,
      :audit_record_modified_date,
      :audit_record_modified_by,
    ]
  end

  private

  def csv_row(loan, sequence, previous_state)
    LoanAuditReportCsvRow.new(loan, sequence, previous_state)
  end

  def each_record(&block)
    previous_loan_id = nil
    sequence = 0
    previous_state = nil

    iterator = ->(record) do
      if previous_loan_id != record.id
        sequence = 0
        previous_state = nil
      end

      block.call(record, sequence, previous_state)

      sequence += 1
      previous_state = record.loan_state_change_to_state
      previous_loan_id = record.id
    end

    super(&iterator)
  end

end
