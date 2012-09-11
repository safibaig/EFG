class DataCorrectionsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan

  def new
    @loan_change = @loan.loan_changes.new
  end

  def create
    @loan_change = @loan.loan_changes.new
    @loan_change.attributes = params[:loan_change]
    @loan_change.date_of_change = Date.current
    @loan_change.change_type_id = '9' # Used for all data corrections.
    @loan_change.created_by = current_user
    @loan_change.modified_date = Date.current

    if @loan_change.save_and_update_loan
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.correctable.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanChange)
    end
end
