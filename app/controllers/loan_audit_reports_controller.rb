class LoanAuditReportsController < ApplicationController

  def new
    @loan_audit_report = LoanAuditReport.new
    @loan_events = LoanEvent.all.sort_by(&:name)
  end

  def create
    @loan_audit_report = LoanAuditReport.new(params[:loan_audit_report])
    if @loan_audit_report.valid?
      respond_to do |format|
        format.html { render 'summary' }
        format.csv do
          filename = "#{Date.today.to_s(:db)}_loan_audit_report.csv"
          csv_export = LoanAuditReportCsvExport.new(@loan_audit_report.loans)
          send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
        end
      end
    else
      render :new
    end
  end

end
