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
      render :new and return
    end

    respond_to do |format|
      format.html
      format.csv do
        filename = "loan_recoveries_#{@realisation_statement.lender.name.parameterize}_#{Date.today.to_s(:db)}.csv"
        csv_export = LoanRecoveriesCsvExport.new(@realisation_statement.recoveries)
        stream_response(csv_export, filename)
      end
    end
  end

  def create
    @realisation_statement = RealisationStatement.new(params[:realisation_statement])
    @realisation_statement.created_by = current_user

    if @realisation_statement.save_and_realise_loans
      redirect_to realise_loan_url(@realisation_statement)
    else
      render :select_loans
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationStatement)
  end

end
