class PremiumSchedulesController < ApplicationController
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:show]

  before_filter :load_loan
  before_filter :load_premium_schedule, only: [:edit, :update]

  def edit
  end

  def show
    @premium_schedule = @loan.premium_schedule
  end

  def update
    @premium_schedule.attributes = params[:premium_schedule]
    @premium_schedule.calc_type = PremiumSchedule::SCHEDULE_TYPE
    @premium_schedule.reset_euro_conversion_rate

    if @premium_schedule.save
      redirect_to leave_premium_schedule_path(@loan)
    else
      render :edit
    end
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def load_premium_schedule
    @premium_schedule = @loan.premium_schedule || @loan.premium_schedules.build
    @premium_schedule.initial_draw_amount ||= @loan.amount.dup
    @premium_schedule.repayment_duration ||= @loan.repayment_duration.total_months
  end

  helper_method :leave_premium_schedule_path
  def leave_premium_schedule_path(loan)
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
    enforce_update_permission(PremiumSchedule)
  end

  def verify_view_permission
    enforce_view_permission(PremiumSchedule)
  end
end
