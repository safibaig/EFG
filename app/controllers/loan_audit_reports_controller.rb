class LoanAuditReportsController < ApplicationController
  before_filter :verify_create_permission

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
          self.response.headers["Content-Type"] = "text/csv"
          self.response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
          self.response.headers["Last-Modified"] = Time.now.ctime.to_s
          self.response_body = csv_export
        end
      end
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanAuditReport)
  end

end
