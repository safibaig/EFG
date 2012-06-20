module LoanAlerts
  extend ActiveSupport::Concern

  NotProgressedStartDate = 183.days.ago.to_date
  NotProgressedEndDate = 124.days.ago.to_date

  NotDrawnStartDate = 183.days.ago.to_date
  NotDrawnEndDate = 124.days.ago.to_date

  DemandedStartDate = 365.days.ago.to_date
  DemandedEndDate = 306.days.ago.to_date

  AssumedRepaidOfferedStartDate = 183.days.ago.to_date
  AssumedRepaidOfferedEndDate = 124.days.ago.to_date

  AssumedRepaidGuaranteedStartDate = 92.days.ago.to_date
  AssumedRepaidGuaranteedEndDate = 33.days.ago.to_date

  # From 'CfEL Response to Initial Questions.docx':
  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 183 days from entering those states – should be ‘auto cancelled’"
  def unprogressed_loans(start_date = NotProgressedStartDate, end_date = NotProgressedEndDate)
    current_lender.loans.
      unprogressed.
      last_updated_between(start_date, end_date).
      order(:updated_at)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "Offered loans have 183 days to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans(start_date = NotDrawnStartDate, end_date = NotDrawnEndDate)
    current_lender.loans.
      offered.
      last_updated_between(start_date, end_date).
      order(:updated_at)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  #
  # TODO: "EFG loans however, should not be subjected to this alert
  # – they should remain at lender demand indefinitely until such time that the lender themselves progress them"
  def demanded_loans(start_date = DemandedStartDate, end_date = DemandedEndDate)
    current_lender.loans.
      demanded.
      last_updated_between(start_date, end_date).
      order(:updated_at)
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
  # TODO: revisit the criteria for assumed repaid alert group and confirm if it needs further updates
  def assumed_repaid_offered_loans(start_date = AssumedRepaidOfferedStartDate, end_date = AssumedRepaidOfferedEndDate)
    current_lender.loans.
      where(:state => [Loan::Incomplete, Loan::Completed, Loan::Offered]).
      maturity_date_between(start_date, end_date).
      order(:updated_at)
  end

  def assumed_repaid_guaranteed_loans(start_date = AssumedRepaidGuaranteedStartDate, end_date = AssumedRepaidGuaranteedEndDate)
    current_lender.loans.
      guaranteed.
      maturity_date_between(start_date, end_date).
      order(:updated_at)
  end

end
