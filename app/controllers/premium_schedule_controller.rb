class PremiumScheduleController < ApplicationController
  def show
    @loan = current_lender.loans.find(params[:loan_id])
    @premium_schedule = @loan.premium_schedule
    enforce_update_permission(@premium_schedule)
  end
end
