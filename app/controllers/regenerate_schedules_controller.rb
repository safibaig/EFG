class RegenerateSchedulesController < ApplicationController
  before_filter :verify_create_permission
  before_filter :load_loan

  def new
    @state_aid_calculation = @loan.state_aid_calculations.build
  end

  def create
    @state_aid_calculation = @loan.state_aid_calculations.build(params[:state_aid_calculation])
    @state_aid_calculation.rescheduling = true

    if @state_aid_calculation.valid?
      redirect_to new_loan_loan_change_path(
        state_aid_calculation: params[:state_aid_calculation],
        loan_change: params[:loan_change]
      )
    else
      render :new
    end
  end

  private

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def verify_create_permission
    enforce_create_permission(StateAidCalculation)
  end

end
