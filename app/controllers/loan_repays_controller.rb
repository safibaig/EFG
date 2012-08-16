class LoanRepaysController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_repay = LoanRepay.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_repay = LoanRepay.new(@loan)
    @loan_repay.attributes = params[:loan_repay]
    @loan_repay.modified_by = current_user

    if @loan_repay.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanRepay)
  end
end
