class LoanAuditReportCsvRow

  def initialize(loan, sequence, previous_state = nil)
    @loan = loan
    @sequence = sequence
    @previous_state = previous_state
  end

  def row
    [
      @loan.reference,
      @loan.lender_reference_code,
      @loan.amount.try(:format),
      @loan.maturity_date.try(:strftime, '%d-%m-%Y'),
      @loan.cancelled_on.try(:strftime, '%d-%m-%Y'),
      @loan.facility_letter_date.try(:strftime, '%d-%m-%Y'),
      @loan.initial_draw_date.try(:strftime, '%d-%m-%Y'),
      @loan.borrower_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.repaid_on.try(:strftime, '%d-%m-%Y'),
      @loan.no_claim_on.try(:strftime, '%d-%m-%Y'),
      @loan.dti_demanded_on.try(:strftime, '%d-%m-%Y'),
      @loan.settled_on.try(:strftime, '%d-%m-%Y'),
      @loan.remove_guarantee_on.try(:strftime, '%d-%m-%Y'),
      @loan.generic1,
      @loan.generic2,
      @loan.generic3,
      @loan.generic4,
      @loan.generic5,
      @loan.reason.try(:name),
      @loan.loan_category.try(:name),
      @loan.state.humanize,
      @loan.created_at.try(:strftime, "%d-%m-%Y %I:%M %p"),
      @loan.loan_created_by,
      @loan.updated_at.try(:strftime, "%d-%m-%Y %I:%M %p"),
      @loan.loan_modified_by,
      @sequence.to_s,
      from_state,
      @loan.loan_state_change_to_state.humanize,
      event_name,
      @loan.loan_state_change_modified_on.try(:strftime, "%d-%m-%Y %I:%M %p"),
      @loan.loan_state_change_modified_by
    ]
  end

  private

  def from_state
    @previous_state.nil? ? 'Created' : @previous_state.humanize
  end

  def event_name
    if [0, 1].include?(@loan.loan_state_change_event_id)
      'Check eligibility'
    else
      LoanEvent.find(@loan.loan_state_change_event_id).name
    end
  end

end
