class LoanTransfersController < ApplicationController
  before_filter :verify_create_permission

  def show
    @loan = current_lender.loans.find(params[:id])
  end

  def new
    @loan_transfer = LoanTransfer::Sflg.new(Loan.new)
  end

  def create
    @loan_transfer = LoanTransfer::Sflg.new(Loan.new)
    @loan_transfer.attributes = params[:loan_transfer_sflg]
    @loan_transfer.lender = current_lender
    @loan_transfer.modified_by = current_user

    if @loan_transfer.save
      redirect_to loan_transfer_path(@loan_transfer.new_loan)
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanTransfer::Sflg)
  end

end
