class LoanAlertsController < ApplicationController
  include LoanAlerts

  before_filter :verify_view_permission
  before_filter :verify_priority

  def not_progressed
    alert = NotProgressedLoanAlert.new(current_lender, params[:priority])
    @loans = alert.loans
    render "show"
  end

  def not_drawn
    alert = NotDrawnLoanAlert.new(current_lender, params[:priority])
    @loans = alert.loans
    render "show"
  end

  def not_demanded
    alert = NotDemandedLoanAlert.new(current_lender, params[:priority])
    @loans = alert.loans
    render "show"
  end

  def not_closed
    not_closed_offered_alert = NotClosedOfferedLoanAlert.new(current_lender, params[:priority])
    not_closed_guaranteed_alert = NotClosedGuaranteedLoanAlert.new(current_lender, params[:priority])

    alert = CombinedLoanAlert.new(not_closed_offered_alert, not_closed_guaranteed_alert)
    @loans = alert.loans
    render "show"
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
