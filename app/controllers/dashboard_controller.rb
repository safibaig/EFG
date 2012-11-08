class DashboardController < ApplicationController

  include LoanAlerts

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
    LoanAlerts::PriorityGrouping.for_alert(NotDrawnLoanAlert, current_lender, :facility_letter_date).groups_hash
  end

  def not_demanded_loans_groups
    LoanAlerts::PriorityGrouping.for_alert(NotDemandedLoanAlert, current_lender, :borrower_demanded_on).groups_hash
  end

  def not_progressed_loans_groups
    LoanAlerts::PriorityGrouping.for_alert(NotProgressedLoanAlert, current_lender, :updated_at).groups_hash
  end

  def not_closed_loans_groups
    offered_group = LoanAlerts::PriorityGrouping.for_alert(NotClosedOfferedLoanAlert, current_lender, :maturity_date).groups_hash
    guaranteed_group = LoanAlerts::PriorityGrouping.for_alert(NotClosedGuaranteedLoanAlert, current_lender, :maturity_date).groups_hash
    LoanAlerts::PriorityGrouping.merge_groups(offered_group, guaranteed_group)
  end

end
