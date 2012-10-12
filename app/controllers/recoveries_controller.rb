class RecoveriesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan

  def new
    @recovery = @loan.recoveries.new
    @recovery.created_by = current_user
    @recovery.set_total_proceeds_recovered
  end

  def create
    @recovery = @loan.recoveries.new
    @recovery.attributes = params[:recovery]
    @recovery.created_by = current_user
    @recovery.set_total_proceeds_recovered
    @recovery.calculate if @recovery.valid?

    if params[:commit] == 'Submit' && @recovery.save_and_update_loan
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.recoverable.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(Recovery)
    end
end
