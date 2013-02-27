class LoanAlertsController < ApplicationController
  ALERTS = {
    'not_closed'     => LoanAlerts::NotClosedLoanAlert,
    'not_demanded'   => LoanAlerts::NotDemandedLoanAlert,
    'not_drawn'      => LoanAlerts::NotDrawnLoanAlert,
    'not_progressed' => LoanAlerts::NotProgressedLoanAlert
  }

  before_filter :verify_view_permission

  def show
    klass = ALERTS.fetch(params[:id]) { raise ActiveRecord::RecordNotFound }
    @alert = klass.new(current_lender, params[:priority])
  end

  private

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end
end
