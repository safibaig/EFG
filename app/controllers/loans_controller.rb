class LoansController < ApplicationController
  before_filter :load_loan, only: [:show, :details]

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

  private
  def load_loan
    @loan = current_lender.loans.find(params[:id])
  end

  def generate_csv(loan)
    filename = "loan_#{@loan.reference}_#{Date.today.to_s(:db)}.csv"
    csv_export = LoanCsvExport.new([ loan ])
    send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
  end
end
