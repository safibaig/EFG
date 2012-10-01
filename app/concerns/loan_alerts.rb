module LoanAlerts

  def not_progressed_start_date
    183.days.ago.to_date
  end

  def not_progressed_end_date
    124.days.ago.to_date
  end

  # TODO: change to 6 months + 10 days
  def not_drawn_start_date
    183.days.ago.to_date
  end

  def not_drawn_end_date
    124.days.ago.to_date
  end

  def demanded_start_date
    365.days.ago.to_date
  end

  def demanded_end_date
    306.days.ago.to_date
  end

  def assumed_repaid_offered_start_date
    183.days.ago.to_date
  end

  def assumed_repaid_offered_end_date
    124.days.ago.to_date
  end

  def assumed_repaid_guaranteed_start_date
    92.days.ago.to_date
  end

  def assumed_repaid_guaranteed_end_date
    33.days.ago.to_date
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 183 days from entering those states – should be ‘auto cancelled’"
  def not_progressed_loans(start_date = nil, end_date = nil)
    start_date ||= not_progressed_start_date
    end_date ||= not_progressed_end_date

    current_lender.loans.
      not_progressed.
      last_updated_between(start_date, end_date).
      order(:updated_at)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "Offered loans have 183 days to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans(start_date = nil, end_date = nil)
    start_date ||= not_drawn_start_date
    end_date ||= not_drawn_end_date

    current_lender.loans.
      offered.
      facility_letter_date_between(start_date, end_date).
      order(:updated_at)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  #
  # TODO: "EFG loans however, should not be subjected to this alert
  # – they should remain at lender demand indefinitely until such time that the lender themselves progress them"
  def demanded_loans(start_date = nil, end_date = nil)
    start_date ||= demanded_start_date
    end_date ||= demanded_end_date

    current_lender.loans.
      demanded.
      borrower_demanded_date_between(start_date, end_date).
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
  def assumed_repaid_offered_loans(start_date = nil, end_date = nil)
    start_date ||= assumed_repaid_offered_start_date
    end_date ||= assumed_repaid_offered_end_date

    current_lender.loans.
      where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).
      maturity_date_between(start_date, end_date).
      order(:updated_at)
  end

  def assumed_repaid_guaranteed_loans(start_date = nil, end_date = nil)
    start_date ||= assumed_repaid_guaranteed_start_date
    end_date ||= assumed_repaid_guaranteed_end_date

    current_lender.loans.
      guaranteed.
      maturity_date_between(start_date, end_date).
      order(:updated_at)
  end

end
