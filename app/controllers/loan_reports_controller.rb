class LoanReportsController < ApplicationController

  before_filter :sanitize_lender_ids, only: [:create]

  def new
    @loan_report = LoanReport.new
  end

  def create
    @loan_report = LoanReport.new(params[:loan_report])
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

  # Ensure only lender IDs that the current user can access are used for the report
  def sanitize_lender_ids
    return unless params[:loan_report][:lender_ids].present?

    current_user_lender_ids = current_user.lenders.collect(&:id)
    params[:loan_report][:lender_ids] = params[:loan_report][:lender_ids].select do |id|
      current_user_lender_ids.include?(id.to_i)
    end
  end

end
