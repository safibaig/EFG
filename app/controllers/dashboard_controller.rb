class DashboardController < ApplicationController

  def show
    @utilisation_presenter            = UtilisationPresenter.new(current_lender)
    @not_drawn_alerts_presenter       = LoanAlerts::Presenter.new(not_drawn_loans_groups)
    @demanded_alerts_presenter        = LoanAlerts::Presenter.new(demanded_loans_groups)
    @unprogressed_alerts_presenter    = LoanAlerts::Presenter.new(unprogressed_loans_groups)
    @assumed_repaid_presenter         = LoanAlerts::Presenter.new(assumed_repaid_loans_groups)
  end

  private

  # From 'CfEL Response to Initial Questions.docx':
  # "Offered loans have 183 days to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans_groups
    start_date, end_date = 183.days.ago.to_date, 124.days.ago.to_date

    not_drawn_loans = current_lender.loans.offered.last_updated_between(start_date, end_date)
    LoanAlerts::PriorityGrouping.new(not_drawn_loans, start_date, end_date).groups_hash
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  #
  # TODO: "EFG loans however, should not be subjected to this alert
  # – they should remain at lender demand indefinitely until such time that the lender themselves progress them"
  def demanded_loans_groups
    start_date, end_date = 365.days.ago.to_date, 306.days.ago.to_date

    demanded_loans = current_lender.loans.demanded.last_updated_between(start_date, end_date)
    LoanAlerts::PriorityGrouping.new(demanded_loans, start_date, end_date).groups_hash
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 183 days from entering those states – should be ‘auto cancelled’"
  def unprogressed_loans_groups
    start_date, end_date = 183.days.ago.to_date, 124.days.ago.to_date

    unprogressed_loans = current_lender.loans.unprogressed.last_updated_between(start_date, end_date)
    LoanAlerts::PriorityGrouping.new(unprogressed_loans, start_date, end_date).groups_hash
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "Legacy or new scheme loans – if maturity date has elapsed by 183 days – auto remove
  # EFG – if state ‘incomplete’ to ‘offered’ and maturity date elapsed by 183 days – auto remove
  # EFG – if state ‘guaranteed’ and maturity date elapsed by 92 days – auto remove
  # EFG – if state ‘lender demand’ or demanded – just leave alone
  #       i.e. don’t remove – leave at those states indefinitely"
  #
  # NOTE: This method currently implements:
  # - state ‘incomplete’ to ‘offered’ and maturity date elapsed by 183 days
  # - state ‘guaranteed’ and maturity date elapsed by 92 days
  #
  # TODO: revisit the criteria for this alert group and confirm if it needs further updates
  def assumed_repaid_loans_groups
    start_date, end_date = 183.days.ago, 124.days.ago
    assumed_repaid_loans1 = current_lender.loans.where(:state => [Loan::Incomplete, Loan::Completed, Loan::Offered]).maturity_date_between(start_date, end_date)
    group1 = LoanAlerts::PriorityGrouping.new(assumed_repaid_loans1, start_date, end_date, :maturity_date).groups_hash

    start_date, end_date = 92.days.ago, 33.days.ago
    assumed_repaid_loans2 = current_lender.loans.guaranteed.maturity_date_between(start_date, end_date)
    group2 = LoanAlerts::PriorityGrouping.new(assumed_repaid_loans2, start_date, end_date, :maturity_date).groups_hash

    LoanAlerts::PriorityGrouping.merge_groups(group2, group1)
  end

end


