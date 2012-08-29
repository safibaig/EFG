class LoansController < ApplicationController
  before_filter :verify_view_permission
  before_filter :load_loan, only: [:show, :details, :audit_log]

  def show
    respond_to do |format|
      format.html
      format.csv { generate_csv(@loan) }
    end
  end

  def details
    respond_to do |format|
      format.html
      format.csv { generate_csv(@loan) }
    end
  end

  def audit_log
    @audit_log_entries = LoanAuditLogEntries.new(@loan.state_changes)
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:id])
  end

  def generate_csv(loan)
    filename = "loan_#{@loan.reference}_#{Date.today.to_s(:db)}.csv"
    csv_export = LoanCsvExport.new([ loan ])
    send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
  end

  def verify_view_permission
    enforce_view_permission(Loan)
  end
end
