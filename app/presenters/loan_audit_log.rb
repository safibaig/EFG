class LoanAuditLog

  attr_reader :loan_state_change, :previous_state_change

  def self.generate(loan_state_changes)
    previous_state_change = nil

    loan_state_changes.map do |loan_state_change|
      loan_audit_log = new(loan_state_change, previous_state_change)
      previous_state_change = loan_state_change
      loan_audit_log
    end
  end

  def initialize(loan_state_change, previous_state_change = nil)
    @loan_state_change = loan_state_change
    @previous_state_change = previous_state_change
  end

  # event ID 0 == 'Accept', 1 == 'Reject'
  def event_name
    [0, 1].include?(loan_state_change.event_id) ? 'Check Eligibility' : loan_state_change.event.name
  end

  # The initial from state for a loan will always be 'Created'
  def from_state
    previous_state_change.present? ? previous_state_change.state.humanize : 'Created'
  end

  def to_state
    loan_state_change.state.humanize
  end

  def modified_at
    loan_state_change.modified_at.strftime("%d/%m/%Y %I:%M")
  end

  def modified_by
    loan_state_change.modified_by.name
  end

end
