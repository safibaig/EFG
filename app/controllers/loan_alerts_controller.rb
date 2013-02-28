class LoanAlertsController < ApplicationController
  ALERTS = {
    'not_closed'     => LoanAlerts::NotClosedLoanAlert,
    'not_demanded'   => LoanAlerts::NotDemandedLoanAlert,
    'not_drawn'      => LoanAlerts::NotDrawnLoanAlert,
    'not_progressed' => LoanAlerts::NotProgressedLoanAlert
  }

  before_filter :verify_view_permission

  def show
    action = params[:id]
    klass = ALERTS.fetch(action) { raise ActiveRecord::RecordNotFound }
    @alert = klass.new(current_lender, params[:priority])

    respond_to do |format|
      format.html
      format.csv {
        filename = [action, @alert.priority].reject(&:blank?).join('-')
        csv_export = LoanCsvExport.new(@alert.loans)
        stream_response(csv_export, filename)
      }
    end
  end

  private

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end
end
