class StateAidCalculationsController < ApplicationController
  before_filter :load_loan, only: [:edit, :update]
  before_filter :load_state_aid_calculation, only: [:edit, :update]

  def edit
    enforce_update_permission(StateAidCalculation)
  end

  def update
    enforce_update_permission(StateAidCalculation)
    @state_aid_calculation.attributes = params[:state_aid_calculation]

    if @state_aid_calculation.save
      redirect_to leave_state_aid_calculation_path(@loan)
    else
      render :edit
    end
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def load_state_aid_calculation
    @state_aid_calculation = @loan.state_aid_calculation || @loan.build_state_aid_calculation
    @state_aid_calculation.initial_draw_amount ||= @loan.amount.dup
  end

  helper_method :leave_state_aid_calculation_path
  def leave_state_aid_calculation_path(loan)
    if params[:redirect] == 'loan_entry'
      new_loan_entry_path(loan)
    else
      loan_path(loan)
    end
  end
end
