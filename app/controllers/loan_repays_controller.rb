class LoanRepaysController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_repay = LoanRepay.new(@loan)
    enforce_create_permission(@loan_repay)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_repay = LoanRepay.new(@loan)
    @loan_repay.attributes = params[:loan_repay]

    if @loan_repay.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end
end
