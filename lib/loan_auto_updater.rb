module LoanAutoUpdater
  extend self
  extend LoanAlerts

  def cancel_not_progressed_loans!
    loans.not_progressed.where("updated_at < ?", not_progressed_start_date).each do |loan|
      loan.auto_update!(Loan::AutoCancelled, 6)
    end
  end

  def cancel_not_drawn_loans!
    loans.offered.where("facility_letter_date < ?", not_drawn_start_date).each do |loan|
      loan.auto_update!(Loan::AutoCancelled, 8)
    end
  end

  def remove_guarantee_from_not_demanded_loans!
    loans.with_scheme('non_efg').lender_demanded.where("borrower_demanded_on < ?", demanded_start_date).each do |loan|
      loan.auto_update!(Loan::AutoRemoved, 11)
    end
  end

  def remove_not_closed_loans!
    (not_yet_guaranteed_efg_loans + guaranteed_efg_loans + sflg_and_legacy_sflg_loans_in_any_state).uniq.each do |loan|
      loan.auto_update!(Loan::AutoRemoved, 17)
    end
  end

  private

  def loans
    Loan.where(lender_id: Lender.where(allow_alert_process: true))
  end

  def not_yet_guaranteed_efg_loans
    loans.with_scheme('efg').where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).where("maturity_date < ?", not_closed_offered_start_date)
  end

  def guaranteed_efg_loans
    loans.with_scheme('efg').guaranteed.where("maturity_date < ?", not_closed_guaranteed_start_date)
  end

  def sflg_and_legacy_sflg_loans_in_any_state
    loans.with_scheme('non_efg').where("maturity_date < ?", sflg_not_closed_start_date)
  end

end
