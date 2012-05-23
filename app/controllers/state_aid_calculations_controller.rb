class StateAidCalculationsController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @state_aid_calculation = @loan.build_state_aid_calculation
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @state_aid_calculation = @loan.build_state_aid_calculation
    @state_aid_calculation.attributes = params[:state_aid_calculation]

    if @state_aid_calculation.save
      redirect_to @loan
    else
      render :new
    end
  end
end
