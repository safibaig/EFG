class LoanNoClaimsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_no_claim = LoanNoClaim.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_no_claim = LoanNoClaim.new(@loan)
    @loan_no_claim.attributes = params[:loan_no_claim]
    @loan_no_claim.modified_by = current_user

    if @loan_no_claim.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanNoClaim)
  end
end
