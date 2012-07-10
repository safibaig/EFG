class RealiseLoansController < ApplicationController

  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    enforce_view_permission(RealisationStatement)
    @realisation_statement = RealisationStatement.find(params[:id])
  end

  def new
    @realisation_statement = RealisationStatement.new
  end

  def select_loans
    @realisation_statement = RealisationStatement.new(params[:realisation_statement])

    if @realisation_statement.invalid?(:details)
      render :new
    end
  end

  def create
    @realisation_statement = RealisationStatement.new(params[:realisation_statement])
    @realisation_statement.created_by = current_user

    if @realisation_statement.save
      redirect_to realise_loans_path(@realisation_statement)
    else
      render :select_loans
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationStatement)
  end

end
