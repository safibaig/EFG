class LoanDemandAgainstGovernmentController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_against_government = LoanDemandAgainstGovernment.new(@loan)
    @loan_demand_against_government.dti_demanded_on = Date.today
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_against_government = LoanDemandAgainstGovernment.new(@loan)
    @loan_demand_against_government.attributes = params[:loan_demand_against_government]
    @loan_demand_against_government.dti_demanded_on = Date.today
    @loan_demand_against_government.modified_by = current_user

    if @loan_demand_against_government.save
      flash[:notice] = I18n.t(
        'activemodel.loan_demand_against_government.amount_claimed',
        amount: @loan.dti_amount_claimed.format
      )
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanDemandAgainstGovernment)
  end
end
