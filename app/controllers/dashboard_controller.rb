class DashboardController < ApplicationController

  include LoanAlerts

  def show
    if current_user.can_view?(LoanAlerts)
      @lending_limit_utilisations      = setup_lending_limit_utilisations
      @not_drawn_alerts_presenter      = LoanAlerts::Presenter.new(not_drawn_loans_groups)
      @demanded_alerts_presenter       = LoanAlerts::Presenter.new(demanded_loans_groups)
      @not_progressed_alerts_presenter = LoanAlerts::Presenter.new(not_progressed_loans_groups)
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
    LoanAlerts::PriorityGrouping.new(not_drawn_loans, not_drawn_start_date, not_drawn_end_date, :facility_letter_date).groups_hash
  end

  def demanded_loans_groups
    LoanAlerts::PriorityGrouping.new(demanded_loans, demanded_start_date, demanded_end_date, :borrower_demanded_on).groups_hash
  end

  def not_progressed_loans_groups
    LoanAlerts::PriorityGrouping.new(not_progressed_loans, not_progressed_start_date, not_progressed_end_date).groups_hash
  end

  def not_closed_loans_groups
    offered_group = LoanAlerts::PriorityGrouping.new(
      not_closed_offered_loans,
      not_closed_offered_start_date,
      not_closed_offered_end_date,
      :maturity_date
    ).groups_hash

    guaranteed_group = LoanAlerts::PriorityGrouping.new(
      not_closed_guaranteed_loans,
      not_closed_guaranteed_start_date,
      not_closed_guaranteed_end_date,
      :maturity_date
    ).groups_hash

    LoanAlerts::PriorityGrouping.merge_groups(offered_group, guaranteed_group)
  end

end
