class LoanReportsController < ApplicationController

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
          csv_data = @loan_report.to_csv
          send_data(csv_data, type: 'text/csv', filename: filename, disposition: 'attachment')
        end
      end
    else
      render :new
    end
  end

  private

  # ensure allowed_lender_ids is included in loan_report params
  def loan_report_params
    allowed_lender_ids = current_user.lenders.collect(&:id)
    params[:loan_report].merge(allowed_lender_ids: allowed_lender_ids)
  end

end
