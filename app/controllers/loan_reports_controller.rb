class LoanReportsController < ApplicationController
  before_filter :verify_create_permission

  def new
    @loan_report = LoanReport.new
  end

  def create
    @loan_report = LoanReport.new(loan_report_params)
    if @loan_report.valid?
      respond_to do |format|
        format.html { render 'summary' }
        format.csv do
          filename = "#{Date.today.to_s(:db)}_loan_report.csv"
          csv_export = LoanReportCsvExport.new(@loan_report.loans)
          stream_response(csv_export, filename)
        end
      end
    else
      render :new
    end
  end

  private

  # ensure
  # - allowed_lender_ids is included in loan_report params
  # - loan scheme is set to 'E' in loan_report params if current lender can only access EFG loans
  def loan_report_params
    unless current_lender.can_access_all_loan_schemes?
      params[:loan_report].merge!(loan_scheme: Lender::EFG_SCHEME)
    end
    params[:loan_report].merge(allowed_lender_ids: current_user.lenders.collect(&:id))
  end

  def verify_create_permission
    enforce_create_permission(LoanReport)
  end

end
