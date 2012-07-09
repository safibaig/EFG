class LoanGuaranteesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_guarantee = LoanGuarantee.new(@loan)
    @loan_guarantee.attributes = params[:loan_guarantee]

    if @loan_guarantee.save
      redirect_to loan_url(@loan_guarantee.loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanGuarantee)
  end
end
