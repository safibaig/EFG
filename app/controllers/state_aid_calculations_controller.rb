# See app/concerns/state_aid_calculation_variant/base.rb for documentation
# for the following methods:
#  * leave_state_aid_calculation_path
#  * page_header
#  * update_flash_message
class StateAidCalculationsController < ApplicationController
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :load_loan, only: [:edit, :update]
  before_filter :load_state_aid_calculation, only: [:edit, :update]
  before_filter :extend_variant, only: [:edit, :update]

  # There are a number of variants (modules) for the
  # StateAidCalculationsController.
  #
  # They get extended onto the controller depending on the value of the
  # :variant parameter to alter the behaviour.
  DEFAULT_VARIANT = StateAidCalculationVariant::Base
  VARIANTS = [
    StateAidCalculationVariant::LoanEntry,
    StateAidCalculationVariant::LoanGuarantee,
    StateAidCalculationVariant::TransferredLoanEntry,
  ].index_by(&:to_param)

  def edit
  end

  def update
    @state_aid_calculation.attributes = params[:state_aid_calculation]
    @state_aid_calculation.calc_type = StateAidCalculation::SCHEDULE_TYPE

    if @state_aid_calculation.save
      flash[:info] = update_flash_message(@state_aid_calculation)
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
    @state_aid_calculation.initial_draw_months ||= @loan.repayment_duration.total_months
  end

  def extend_variant
    variant = VARIANTS[params[:variant]] || DEFAULT_VARIANT
    extend(variant)
  end

  helper_method :leave_state_aid_calculation_path
  helper_method :page_header

  def verify_update_permission
    enforce_update_permission(StateAidCalculation)
  end
end
