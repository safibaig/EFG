class LoanAlertsController < ApplicationController
  include LoanAlerts

  before_filter :verify_view_permission

  def not_progressed
    start_date, end_date = start_and_end_dates(not_progressed_start_date, not_progressed_end_date)

    @loans = not_progressed_loans(start_date, end_date)
    @title = I18n.t('dashboard.loan_alerts.not_progressed')
    render "show"
  end

  def not_drawn
    start_date, end_date = start_and_end_dates(not_drawn_start_date, not_drawn_end_date)

    @loans = not_drawn_loans(start_date, end_date)
    @title = I18n.t('dashboard.loan_alerts.not_drawn')
    render "show"
  end

  def demanded
    start_date, end_date = start_and_end_dates(demanded_start_date, demanded_end_date)

    @loans = demanded_loans(start_date, end_date)
    @title = I18n.t('dashboard.loan_alerts.demanded')
    render "show"
  end

  def not_closed
    offered_start_date, offered_end_date = start_and_end_dates(not_closed_offered_start_date, not_closed_offered_end_date)
    guaranteed_start_date, guaranteed_end_date = start_and_end_dates(not_closed_guaranteed_start_date, not_closed_guaranteed_end_date)

    @loans = (
      not_closed_offered_loans(offered_start_date, offered_end_date) +
        not_closed_guaranteed_loans(guaranteed_start_date, guaranteed_end_date)
    ).sort_by(&:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_closed')
    render "show"
  end

  private

  def start_and_end_dates(default_start_date, default_end_date)
    default_start_date = default_start_date.to_date
    default_start_date = default_start_date.to_date

    case params[:priority]
    when "high"
      start_date = default_start_date
      end_date = (default_start_date + 9.days)
    when "medium"
      start_date = (default_start_date + 10.days)
      end_date = (default_start_date + 29.days)
    when "low"
      start_date = (default_start_date + 30.days)
      end_date = (default_start_date + 59.days)
    else
      start_date = default_start_date
      end_date = default_end_date
    end

    return start_date.to_date, end_date.to_date
  end

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end
end
