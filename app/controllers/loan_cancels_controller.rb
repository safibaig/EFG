class LoanCancelsController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_cancel = LoanCancel.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_cancel = LoanCancel.new(@loan)
    @loan_cancel.attributes = params[:loan_cancel]

    if @loan_cancel.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end
end
