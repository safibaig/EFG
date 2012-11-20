class LoanDemandToBorrowersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_to_borrower = LoanDemandToBorrower.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_to_borrower = LoanDemandToBorrower.new(@loan)
    @loan_demand_to_borrower.attributes = params[:loan_demand_to_borrower]
    @loan_demand_to_borrower.modified_by = current_user

    if @loan_demand_to_borrower.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanDemandToBorrower)
  end
end
