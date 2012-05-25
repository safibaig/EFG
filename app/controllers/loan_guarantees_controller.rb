class LoanGuaranteesController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan, params[:loan_guarantee])
    @loan_guarantee.save
    redirect_to loan_url(@loan_guarantee.loan)
  end
end
