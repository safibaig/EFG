class LoanAuditLogEntries
  include Enumerable

  def initialize(loan_state_changes)
    @loan_state_changes = loan_state_changes
    @previous_state_change = nil
  end

  # Pass the previous LoanStateChanage record to LoanAuditLog so
  # the from state can be determined. This mimmicks the legacy system.
  def each
    @loan_state_changes.each do |loan_state_change|
      yield LoanAuditLog.new(loan_state_change, @previous_state_change)
      @previous_state_change = loan_state_change
    end
  end

end
