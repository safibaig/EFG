module LoanAutoUpdater
  extend self
  extend LoanAlerts

  def cancel_not_progressed_loans!
    loans.not_progressed.where("updated_at < ?", not_progressed_start_date).find_each do |loan|
      loan.update_state!(Loan::AutoCancelled, 6, system_user)
    end
  end

  def cancel_not_drawn_loans!
    loans.offered.where("facility_letter_date < ?", not_drawn_start_date).find_each do |loan|
      loan.update_state!(Loan::AutoCancelled, 8, system_user)
    end
  end

  def remove_not_demanded_loans!
    loans.with_scheme('non_efg').lender_demanded.where("borrower_demanded_on < ?", not_demanded_start_date).find_each do |loan|
      loan.update_state!(Loan::AutoRemoved, 11, system_user)
    end
  end

  def remove_not_closed_loans!
    (not_yet_guaranteed_efg_loans + guaranteed_efg_loans + not_closed_sflg_and_legacy_sflg_loans).uniq.each do |loan|
      loan.update_state!(Loan::AutoRemoved, 17, system_user)
    end
  end

  private

  def loans
    @lender_ids ||= Lender.where(allow_alert_process: true).collect(&:id)
    Loan.where(lender_id: @lender_ids)
  end

  def not_yet_guaranteed_efg_loans
    loans.with_scheme('efg').where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).where("maturity_date < ?", not_closed_offered_start_date)
  end

  def guaranteed_efg_loans
    loans.with_scheme('efg').guaranteed.where("maturity_date < ?", not_closed_guaranteed_start_date)
  end

  def not_closed_sflg_and_legacy_sflg_loans
    loans.
      with_scheme('non_efg').
      where(state: [ Loan::Guaranteed, Loan::LenderDemand ]).
      where("maturity_date < ?", sflg_not_closed_start_date)
  end

  def system_user
    @system_user ||= SystemUser.first
  end

end
