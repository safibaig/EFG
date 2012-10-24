# Comments taken from 'CfEL Response to Initial Questions.docx'
module LoanAlerts

  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 183 days from entering those states – should be ‘auto cancelled’"
  def not_progressed_loans(priority = nil)
    loans_for_alert(:not_progressed, priority) do |loans_scope, start_date, end_date|
      loans_scope.not_progressed.last_updated_between(start_date, end_date).order(:updated_at)
    end
  end

  # "Offered loans have 183 days to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans(priority = nil)
    loans_for_alert(:not_drawn, priority) do |loans_scope, start_date, end_date|
      loans_scope.offered.facility_letter_date_between(start_date, end_date).order(:facility_letter_date)
    end
  end

  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  # "EFG loans however, should not be subjected to this alert
  def demanded_loans(priority = nil)
    loans_for_alert(:demanded, priority) do |loans_scope, start_date, end_date|
      loans_scope.with_scheme('non_efg').lender_demanded.borrower_demanded_date_between(start_date, end_date).order(:borrower_demanded_on)
    end
  end

  # "Legacy or new scheme guaranteed/lender demand loans – if maturity date has elapsed by 183 days – auto remove
  # EFG – if state ‘incomplete’ to ‘offered’ and maturity date elapsed by 183 days – auto remove
  def not_closed_offered_loans(priority = nil)
    sflg_loans = loans_for_alert(:not_closed_offered, priority) do |loans_scope, start_date, end_date|
      loans_scope.
        with_scheme('non_efg').
        where(state: [ Loan::Guaranteed, Loan::LenderDemand ]).
        maturity_date_between(start_date, end_date).
        order(:maturity_date)
    end

    efg_loans = loans_for_alert(:not_closed_offered, priority) do |loans_scope, start_date, end_date|
      loans_scope.with_scheme('efg').where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).maturity_date_between(start_date, end_date).order(:maturity_date)
    end

    (efg_loans + sflg_loans).uniq
  end

  # EFG – if state ‘guaranteed’ and maturity date elapsed by 92 days – auto remove
  def not_closed_guaranteed_loans(priority = nil)
    loans_for_alert(:not_closed_guaranteed, priority) do |loans_scope, start_date, end_date|
      loans_scope.with_scheme('efg').guaranteed.maturity_date_between(start_date, end_date).order(:maturity_date)
    end
  end

  private

  def loans_for_alert(alert_name, priority = nil)
    default_start_date = send("#{alert_name}_start_date")
    default_end_date = send("#{alert_name}_end_date")

    start_date = {
      "high"   => default_start_date,
      "medium" => default_start_date.advance(days: 10),
      "low"    => default_start_date.advance(days: 30)
    }.fetch(priority, default_start_date)

    end_date = {
      "high"   => default_start_date.advance(days: 9),
      "medium" => default_start_date.advance(days: 29),
      "low"    => default_start_date.advance(days: 59)
    }.fetch(priority, default_end_date)

    yield current_lender.loans, start_date, end_date
  end

  def not_progressed_start_date
    6.months.ago.to_date
  end

  def not_progressed_end_date
    6.months.ago.to_date.advance(days: 59)
  end

  def not_drawn_start_date
    6.months.ago.to_date.advance(days: -10)
  end

  def not_drawn_end_date
    6.months.ago.to_date.advance(days: 69)
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
    6.months.ago.to_date.advance(days: 59)
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
    6.months.ago.to_date.advance(days: 59)
  end

end
