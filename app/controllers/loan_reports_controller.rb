class LoanReportsController < ApplicationController
  before_filter :verify_create_permission

  def new
    @loan_report = LoanReportPresenter.new(current_user)
  end

  def create
    @loan_report = LoanReportPresenter.new(current_user, params[:loan_report])
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
  def verify_create_permission
    enforce_create_permission(LoanReport)
  end

end
