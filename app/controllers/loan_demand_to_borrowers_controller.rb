class LoanDemandToBorrowersController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_to_borrower = LoanDemandToBorrower.new(@loan)
    enforce_create_permission(@loan_demand_to_borrower)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_to_borrower = LoanDemandToBorrower.new(@loan)
    @loan_demand_to_borrower.attributes = params[:loan_demand_to_borrower]

    if @loan_demand_to_borrower.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end
end
