class LoanNoClaimsController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_no_claim = LoanNoClaim.new(@loan)
    enforce_create_permission(@loan_no_claim)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_no_claim = LoanNoClaim.new(@loan)
    enforce_create_permission(@loan_no_claim)
    @loan_no_claim.attributes = params[:loan_no_claim]

    if @loan_no_claim.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end
end
