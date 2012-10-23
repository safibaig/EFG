class LoanAlertsController < ApplicationController
  include LoanAlerts

  before_filter :verify_view_permission
  before_filter :verify_priority

  def not_progressed
    @loans = not_progressed_loans(params[:priority])
    render "show"
  end

  def not_drawn
    @loans = not_drawn_loans(params[:priority])
    render "show"
  end

  def not_demanded
    @loans = demanded_loans(params[:priority])
    render "show"
  end

  def not_closed
    @loans = (not_closed_offered_loans(params[:priority]) +
              not_closed_guaranteed_loans(params[:priority])).sort_by(&:maturity_date)
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
