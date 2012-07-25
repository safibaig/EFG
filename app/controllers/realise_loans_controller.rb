class RealiseLoansController < ApplicationController

  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    enforce_view_permission(RealisationStatement)
    realisation_statement = RealisationStatement.find(params[:id])
    @loan_realisations = realisation_statement.loan_realisations.includes(:realised_loan)
  end

  def new
    @realisation_statement = RealisationStatement.new
  end

  def select_loans
    @realisation_statement = RealisationStatement.new(params[:realisation_statement])

    if @realisation_statement.invalid?(:details)
      render :new
    end

    respond_to do |format|
      format.html
      format.csv do
        filename = "loan_recoveries_#{@realisation_statement.lender.name.parameterize}_#{Date.today.strftime('%d-%m-%Y')}.csv"
        csv_export = LoanRecoveriesCsvExport.new(@realisation_statement.recoveries)
        send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
      end
    end
  end

  def create
    @realisation_statement = RealisationStatement.new(params[:realisation_statement])
    @realisation_statement.created_by = current_user

    if @realisation_statement.save_and_realise_loans
      redirect_to realise_loan_path(@realisation_statement)
    else
      render :select_loans
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationStatement)
  end

end
