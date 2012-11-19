class DashboardController < ApplicationController

  def show
    if current_user.can_view?(LoanAlerts)
      @lending_limit_utilisations      = setup_lending_limit_utilisations
      @not_progressed_alerts_presenter = LoanAlerts::Presenter.new(not_progressed_loans_groups)
      @not_drawn_alerts_presenter      = LoanAlerts::Presenter.new(not_drawn_loans_groups)
      @not_demanded_alerts_presenter   = LoanAlerts::Presenter.new(not_demanded_loans_groups)
      @not_closed_presenter            = LoanAlerts::Presenter.new(not_closed_loans_groups)
    end
  end

  private

  def setup_lending_limit_utilisations
    current_lender.lending_limits.active.map do |lending_limit|
      LendingLimitUtilisation.new(lending_limit)
    end
  end

  def not_drawn_loans_groups
    alert = LoanAlerts::NotDrawnLoanAlert.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_demanded_loans_groups
    alert = LoanAlerts::NotDemandedLoanAlert.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_progressed_loans_groups
    alert = LoanAlerts::NotProgressedLoanAlert.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_closed_loans_groups
    offered_alert = LoanAlerts::NotClosedOfferedLoanAlert.new(current_lender)
    offered_group = LoanAlerts::PriorityGrouping.new(offered_alert)

    guaranteed_alert = LoanAlerts::NotClosedGuaranteedLoanAlert.new(current_lender)
    guaranteed_group = LoanAlerts::PriorityGrouping.new(guaranteed_alert)
    LoanAlerts::PriorityGrouping.merge(offered_group, guaranteed_group)
  end

end
