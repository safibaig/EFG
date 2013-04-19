class PremiumScheduleController < ApplicationController
  before_filter :verify_view_permission

  def show
    @loan = current_lender.loans.find(params[:loan_id])
    @premium_schedule = @loan.premium_schedule
  end

  private
    def verify_view_permission
      enforce_view_permission(PremiumSchedule)
    end
end
