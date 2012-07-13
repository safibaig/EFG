class LoanTransfersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan_transfer = LoanTransfer.new
  end

  def create
    @loan_transfer = LoanTransfer.new(params[:loan_transfer])
    @loan_transfer.lender = current_lender

    if @loan_transfer.valid_loan_transfer_request?
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
