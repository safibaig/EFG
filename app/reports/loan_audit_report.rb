class LoanAuditReport < BaseLoanReport

  attr_accessor :state, :lender_id, :event_id

  date_attribute :facility_letter_start_date, :facility_letter_end_date,
                 :created_at_start_date, :created_at_end_date,
                 :last_modified_start_date, :last_modified_end_date,
                 :audit_records_start_date, :audit_records_end_date

  def loans
    Loan.
      select(
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
      ).
      joins("RIGHT OUTER JOIN loan_state_changes ON loans.id = loan_state_changes.loan_id").
      joins("LEFT JOIN loan_modifications AS first_loan_change ON loans.id = first_loan_change.loan_id AND first_loan_change.seq = 0").
      where("loans.modified_by_legacy_id != 'migration'").
      where(query_conditions).
      order("loans.reference, loan_state_changes.version")
  end

  def event_name
    event ? event.name : 'All'
  end

  private

  # Note: facility_letter_start_date/facility_letter_end_date actually queries initial draw date
  #       and includes records that do not have an initial draw date
  def query_conditions_mapping
    {
      state: "loans.state = ?",
      lender_id: "loans.lender_id = ?",
      event_id: "loan_state_changes.event_id = ?",
      facility_letter_start_date: "(first_loan_change.date_of_change >= ? or first_loan_change.date_of_change IS NULL)",
      facility_letter_end_date: "(first_loan_change.date_of_change <= ? or first_loan_change.date_of_change IS NULL)",
      created_at_start_date: "loans.created_at >= ?",
      created_at_end_date: "loans.created_at <= ?",
      last_modified_start_date: "loans.updated_at >= ?",
      last_modified_end_date: "loans.updated_at <= ?",
      audit_records_start_date: "loan_state_changes.modified_at >= ?",
      audit_records_end_date: "loan_state_changes.modified_at <= ?"
    }
  end

  def event
    event_id.present? ? LoanEvent.find(event_id.to_i) : nil
  end

end
