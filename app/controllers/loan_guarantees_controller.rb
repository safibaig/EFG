class LoanGuaranteesController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan)
    enforce_create_permission(@loan_guarantee)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan)
    enforce_create_permission(@loan_guarantee)
    @loan_guarantee.attributes = params[:loan_guarantee]

    if @loan_guarantee.save
      redirect_to loan_url(@loan_guarantee.loan)
    else
      render :new
    end
  end
end
