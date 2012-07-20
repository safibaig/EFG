class LoanChangesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_change = @loan.loan_changes.new
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_change = @loan.loan_changes.new(params[:loan_change])
    @loan_change.created_by = current_user
    @loan_change.modified_date = Date.today

    if @loan_change.save
      redirect_to @loan
    else
      render :new
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(LoanChange)
    end
end
