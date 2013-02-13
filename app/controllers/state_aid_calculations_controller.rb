class StateAidCalculationsController < ApplicationController
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :load_loan, only: [:edit, :update]
  before_filter :load_state_aid_calculation, only: [:edit, :update]

  def edit
  end

  def update
    @state_aid_calculation.attributes = params[:state_aid_calculation]
    @state_aid_calculation.calc_type = StateAidCalculation::SCHEDULE_TYPE

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
    @state_aid_calculation = @loan.state_aid_calculation || @loan.state_aid_calculations.build
    @state_aid_calculation.initial_draw_amount ||= @loan.amount.dup
    @state_aid_calculation.repayment_duration ||= @loan.repayment_duration.total_months
  end

  helper_method :leave_state_aid_calculation_path
  def leave_state_aid_calculation_path(loan)
    if params[:redirect] == 'loan_entry'
      new_loan_entry_path(loan)
    elsif params[:redirect] == 'transferred_loan_entry'
      new_loan_transferred_entry_path(loan)
    elsif params[:redirect] == 'loan_guarantee'
      new_loan_guarantee_path(loan)
    else
      loan_path(loan)
    end
  end

  def verify_update_permission
    enforce_update_permission(StateAidCalculation)
  end
end
