class LoanChangesController < ApplicationController
  before_filter :load_loan, only: [:index, :show]
  before_filter :load_changeable_loan, only: [:new, :create]
  before_filter :verify_create_permission, only: [:new, :create]

  def index
    @loan_changes = @loan.loan_changes
  end

  def show
    @loan_change = @loan.loan_changes.find(params[:id])
  end

  def new
    @loan_change = @loan.loan_changes.new
  end

  def create
    @loan_change = @loan.loan_changes.new(params[:loan_change])
    @loan_change.created_by = current_user
    @loan_change.modified_date = Date.today

    if @loan_change.save_and_update_loan
      redirect_to @loan
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.find(params[:loan_id])
    end

    def load_changeable_loan
      @loan = current_lender.loans
        .where(state: LoanChange::VALID_LOAN_STATES)
        .find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanChange)
    end
end
