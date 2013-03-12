class RegenerateSchedulesController < ApplicationController
  before_filter :verify_create_permission
  before_filter :load_loan

  def new
    @premium_schedule = @loan.premium_schedules.build
  end

  def create
    @premium_schedule = @loan.premium_schedules.build(params[:premium_schedule])
    @premium_schedule.calc_type = PremiumSchedule::RESCHEDULE_TYPE

    if @premium_schedule.valid?
      redirect_to new_loan_loan_change_url(
        premium_schedule: params[:premium_schedule],
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
    enforce_create_permission(PremiumSchedule)
  end

end
