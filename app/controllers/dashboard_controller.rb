class DashboardController < ApplicationController

  include LoanAlerts

  def show
    @utilisation_presenter            = UtilisationPresenter.new(current_lender)
    @not_drawn_alerts_presenter       = LoanAlerts::Presenter.new(not_drawn_loans_groups)
    @demanded_alerts_presenter        = LoanAlerts::Presenter.new(demanded_loans_groups)
    @unprogressed_alerts_presenter    = LoanAlerts::Presenter.new(unprogressed_loans_groups)
    @assumed_repaid_presenter         = LoanAlerts::Presenter.new(assumed_repaid_loans_groups)
  end

  private

  def not_drawn_loans_groups
    LoanAlerts::PriorityGrouping.new(not_drawn_loans, NotDrawnStartDate, NotDrawnEndDate).groups_hash
  end

  def demanded_loans_groups
    LoanAlerts::PriorityGrouping.new(demanded_loans, DemandedStartDate, DemandedEndDate).groups_hash
  end

  def unprogressed_loans_groups
    LoanAlerts::PriorityGrouping.new(unprogressed_loans, NotProgressedStartDate, NotProgressedEndDate).groups_hash
  end

  def assumed_repaid_loans_groups
    offered_group = LoanAlerts::PriorityGrouping.new(
      assumed_repaid_offered_loans,
      AssumedRepaidOfferedStartDate,
      AssumedRepaidOfferedEndDate,
      :maturity_date
    ).groups_hash

    guaranteed_group = LoanAlerts::PriorityGrouping.new(
      assumed_repaid_guaranteed_loans,
      AssumedRepaidGuaranteedStartDate,
      AssumedRepaidGuaranteedEndDate,
      :maturity_date
    ).groups_hash

    LoanAlerts::PriorityGrouping.merge_groups(offered_group, guaranteed_group)
  end

end


