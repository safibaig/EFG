class LoanAlertsController < ApplicationController

  def not_progressed
    start_date, end_date = start_and_end_dates(183.days.ago, 124.days.ago)

    @loans = current_lender.loans.unprogressed.last_updated_between(start_date, end_date).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_progressed')
    render "show"
  end

  def not_drawn
    start_date, end_date = start_and_end_dates(183.days.ago, 124.days.ago)

    @loans = current_lender.loans.offered.last_updated_between(start_date, end_date).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.not_drawn')
    render "show"
  end

  def demanded
    start_date, end_date = start_and_end_dates(365.days.ago, 306.days.ago)

    @loans = current_lender.loans.demanded.last_updated_between(start_date, end_date).order(:updated_at)
    @title = I18n.t('dashboard.loan_alerts.demanded')
    render "show"
  end

  def assumed_repaid
    @loans = (assumed_repaid_loans1 + assumed_repaid_loans2).sort_by(&:updated_at)
    @title = I18n.t('dashboard.loan_alerts.assumed_repaid')
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

  def assumed_repaid_loans1
    start_date, end_date = start_and_end_dates(183.days.ago, 124.days.ago)
    current_lender.loans.where(:state => [Loan::Incomplete, Loan::Completed, Loan::Offered]).maturity_date_between(start_date, end_date)
  end

  def assumed_repaid_loans2
    start_date, end_date = start_and_end_dates(92.days.ago, 33.days.ago)
    assumed_repaid_loans2 = current_lender.loans.guaranteed.maturity_date_between(start_date, end_date)
  end

end
