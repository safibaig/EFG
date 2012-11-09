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
    LoanAlerts::PriorityGrouping.for_alert(LoanAlerts::NotDrawnLoanAlert, current_lender)
  end

  def not_demanded_loans_groups
    LoanAlerts::PriorityGrouping.for_alert(LoanAlerts::NotDemandedLoanAlert, current_lender)
  end

  def not_progressed_loans_groups
    LoanAlerts::PriorityGrouping.for_alert(LoanAlerts::NotProgressedLoanAlert, current_lender)
  end

  def not_closed_loans_groups
    offered_group = LoanAlerts::PriorityGrouping.for_alert(LoanAlerts::NotClosedOfferedLoanAlert, current_lender)
    guaranteed_group = LoanAlerts::PriorityGrouping.for_alert(LoanAlerts::NotClosedGuaranteedLoanAlert, current_lender)
    LoanAlerts::PriorityGrouping.merge(offered_group, guaranteed_group)
  end

end
