class LoanAlertsController < ApplicationController

  def not_drawn
    @loans = current_lender.loans.offered.last_updated_between(*start_and_end_dates).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_drawn')
    render "show"
  end

  def not_demanded
    start_date, end_date = start_and_end_dates(365.days.ago, 306.days.ago)

    @loans = current_lender.loans.lender_demanded.last_updated_between(start_date, end_date).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_demanded')
    render "show"
  end

  def not_progressed
    @loans = current_lender.loans.unprogressed.last_updated_between(*start_and_end_dates).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_progressed')
    render "show"
  end

  private

  def start_and_end_dates(default_start_date = 183.days.ago, default_end_date = 124.days.ago)
    case params[:priority]
    when "high"
      return default_start_date, (default_start_date + 9.days)
    when "medium"
      return (default_start_date + 10.days), (default_start_date + 30.days)
    when "low"
      return (default_start_date + 31.days), (default_start_date + 59.days)
    else
      return default_start_date, default_end_date
    end
  end

end
