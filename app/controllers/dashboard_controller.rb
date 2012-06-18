class DashboardController < ApplicationController
  def show
    @utilisation_presenter = UtilisationPresenter.new(current_lender)

    offered_loans = current_lender.loans.offered.last_updated_between(183.days.ago, 124.days.ago)
    @offered_alerts_presenter = LoanAlerts::Presenter.new(offered_loans, 183.days.ago, 124.days.ago)

    lender_demanded_loans = current_lender.loans.lender_demanded.last_updated_between(365.days.ago, 306.days.ago)
    @lender_demanded_alerts_presenter = LoanAlerts::Presenter.new(lender_demanded_loans, 365.days.ago, 306.days.ago)

    unprogressed_loans = current_lender.loans.unprogressed.last_updated_between(183.days.ago, 124.days.ago)
    @unprogressed_alerts_presenter = LoanAlerts::Presenter.new(unprogressed_loans, 183.days.ago, 124.days.ago)

    # TODO - alert 4 presenter
  end
end
