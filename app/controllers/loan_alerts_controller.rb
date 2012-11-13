class LoanAlertsController < ApplicationController
  before_filter :verify_view_permission
  before_filter :verify_priority

  def not_progressed
    @alert = LoanAlerts::NotProgressedLoanAlert.new(current_lender, params[:priority])
    render :show
  end

  def not_drawn
    @alert = LoanAlerts::NotDrawnLoanAlert.new(current_lender, params[:priority])
    render :show
  end

  def not_demanded
    @alert = LoanAlerts::NotDemandedLoanAlert.new(current_lender, params[:priority])
    render :show
  end

  def not_closed
    not_closed_offered_alert = LoanAlerts::NotClosedOfferedLoanAlert.new(current_lender, params[:priority])
    not_closed_guaranteed_alert = LoanAlerts::NotClosedGuaranteedLoanAlert.new(current_lender, params[:priority])

    @alert = LoanAlerts::CombinedLoanAlert.new(not_closed_offered_alert, not_closed_guaranteed_alert)
    render :show
  end

  private

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end

  def verify_priority
    unless params[:priority].blank? || %w(low medium high).include?(params[:priority])
      raise ArgumentError, "#{params[:priority]} is not allowed. Must be low, medium or high"
    end
  end
end
