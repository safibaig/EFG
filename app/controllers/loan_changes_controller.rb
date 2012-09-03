class LoanChangesController < ApplicationController
  before_filter :verify_view_permission, only: [:index, :show]
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan, only: [:index, :show]
  before_filter :load_changeable_loan, only: [:new, :create]

  def index
    @loan_changes = @loan.loan_changes
  end

  def show
    @loan_change = @loan.loan_changes.find(params[:id])
  end

  def new
    @loan_change = @loan.loan_changes.new(params[:loan_change])
  end

  def create
    if params[:commit] == 'Reschedule'
      redirect_to new_loan_regenerate_schedule_path(loan_change: params[:loan_change]) and return
    end
    @loan_change = @loan.loan_changes.new(params[:loan_change])
    @loan_change.created_by = current_user
    @loan_change.modified_date = Date.today
    @loan_change.state_aid_calculation_attributes = params[:state_aid_calculation]

    if @loan_change.save_and_update_loan
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.find(params[:loan_id])
    end

    def load_changeable_loan
      @loan = current_lender.loans.changeable.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanChange)
    end

    def verify_view_permission
      enforce_view_permission(LoanChange)
    end
end
