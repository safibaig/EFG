class UpdateLoanLendingLimitsController < ApplicationController
  before_filter :load_loan, only: [:new, :create]
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @update_lending_limit = UpdateLoanLendingLimit.new(@loan)
  end

  def create
    @update_lending_limit = UpdateLoanLendingLimit.new(@loan)
    @update_lending_limit.attributes = params[:update_loan_lending_limit]
    @update_lending_limit.modified_by = current_user

    if @update_lending_limit.save
      redirect_to loan_url(@update_lending_limit.loan)
    else
      render :new
    end
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def verify_create_permission
    enforce_create_permission(UpdateLoanLendingLimit)
  end
end
