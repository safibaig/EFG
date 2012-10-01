module LoanAlerts

  def not_progressed_start_date
    6.months.ago.to_date
  end

  def not_progressed_end_date
    (6.months.ago + 59.days).to_date
  end

  def not_drawn_start_date
    (6.months.ago - 10.days).to_date
  end

  def not_drawn_end_date
    (6.months.ago + 69.days).to_date
  end

  def demanded_start_date
    365.days.ago.to_date
  end

  def demanded_end_date
    306.days.ago.to_date
  end

  def not_closed_offered_start_date
    6.months.ago.to_date
  end

  def not_closed_offered_end_date
    (6.months.ago + 59.days).to_date
  end

  def not_closed_guaranteed_start_date
    92.days.ago.to_date
  end

  def not_closed_guaranteed_end_date
    33.days.ago.to_date
  end

  def sflg_not_closed_start_date
    6.months.ago.to_date
  end

  def sflg_not_closed_end_date
    (6.months.ago + 59.days).to_date
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 183 days from entering those states – should be ‘auto cancelled’"
  def not_progressed_loans(priority = nil)
    start_date, end_date = start_and_end_dates(not_progressed_start_date, not_progressed_end_date, priority)

    current_lender.loans.
      not_progressed.
      last_updated_between(start_date, end_date).
      order(:updated_at)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "Offered loans have 183 days to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans(priority = nil)
    start_date, end_date = start_and_end_dates(not_drawn_start_date, not_drawn_end_date, priority)

    current_lender.loans.
      offered.
      facility_letter_date_between(start_date, end_date).
      order(:facility_letter_date)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  # "EFG loans however, should not be subjected to this alert
  def demanded_loans(priority = nil)
    start_date, end_date = start_and_end_dates(demanded_start_date, demanded_end_date, priority)

    current_lender.loans.
      non_efg.
      lender_demanded.
      borrower_demanded_date_between(start_date, end_date).
      order(:borrower_demanded_on)
  end

  # From 'CfEL Response to Initial Questions.docx':
  # "Legacy or new scheme loans – if maturity date has elapsed by 183 days – auto remove
  # EFG – if state ‘incomplete’ to ‘offered’ and maturity date elapsed by 183 days – auto remove
  def not_closed_offered_loans(priority = nil)
    start_date, end_date = start_and_end_dates(not_closed_offered_start_date, not_closed_offered_end_date, priority)

    sflg_loans = current_lender.loans.non_efg.maturity_date_between(start_date, end_date).order(:maturity_date)

    efg_loans = current_lender.loans.
      efg.
      where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).
      maturity_date_between(start_date, end_date).
      order(:maturity_date)

    (efg_loans + sflg_loans).uniq
  end

  # From 'CfEL Response to Initial Questions.docx':
  # EFG – if state ‘guaranteed’ and maturity date elapsed by 92 days – auto remove
  def not_closed_guaranteed_loans(priority = nil)
    start_date, end_date = start_and_end_dates(not_closed_guaranteed_start_date, not_closed_guaranteed_end_date, priority)

    current_lender.loans.
      efg.
      guaranteed.
      maturity_date_between(start_date, end_date).
      order(:maturity_date)
  end

  private

  def start_and_end_dates(default_start_date, default_end_date, priority = nil)
    default_start_date = default_start_date.to_date
    default_start_date = default_start_date.to_date

    case priority
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

end
