class LoanTransfersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan_transfer = LoanTransfer.new(Loan.new)
  end

  def create
    @loan_transfer = LoanTransfer.new(Loan.new)
    @loan_transfer.attributes = params[:loan_transfer]
    @loan_transfer.lender = current_lender

    if @loan_transfer.valid?
      render text: 'worked!'
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanTransfer)
  end

end
