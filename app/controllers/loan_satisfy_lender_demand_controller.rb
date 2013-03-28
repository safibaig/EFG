class LoanSatisfyLenderDemandController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan
  rescue_from_incorrect_loan_state_error

  def new
    @loan_satisfy_lender_demand = LoanSatisfyLenderDemand.new(@loan)
  end

  def create
    @loan_satisfy_lender_demand = LoanSatisfyLenderDemand.new(@loan)
    @loan_satisfy_lender_demand.attributes = params[:loan_satisfy_lender_demand]
    @loan_satisfy_lender_demand.modified_by = current_user

    if @loan_satisfy_lender_demand.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanSatisfyLenderDemand)
    end
end
