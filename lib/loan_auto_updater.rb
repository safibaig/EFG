module LoanAutoUpdater
  extend self

  def cancel_not_progressed_loans!
    loans.not_progressed.where("updated_at < ?", LoanAlerts::NotProgressedLoanAlert.start_date).find_each do |loan|
      loan.update_state!(Loan::AutoCancelled, LoanEvent::NotProgressed, system_user)
    end
  end

  def cancel_not_drawn_loans!
    loans.offered.where("facility_letter_date < ?", LoanAlerts::NotDrawnLoanAlert.start_date).find_each do |loan|
      loan.update_state!(Loan::AutoCancelled, LoanEvent::NotDrawn, system_user)
    end
  end

  def remove_not_demanded_loans!
    loans.with_scheme('non_efg').lender_demanded.where("borrower_demanded_on < ?", LoanAlerts::NotDemandedLoanAlert.start_date).find_each do |loan|
      loan.update_state!(Loan::AutoRemoved, LoanEvent::NotDemanded, system_user)
    end
  end

  def remove_not_closed_loans!
    (guaranteed_efg_loans + not_closed_sflg_and_legacy_sflg_loans).uniq.each do |loan|
      loan.update_state!(Loan::AutoRemoved, LoanEvent::NotClosed, system_user)
    end
  end

  private

  def loans
    @lender_ids ||= Lender.where(allow_alert_process: true).collect(&:id)
    Loan.where(lender_id: @lender_ids)
  end

  def guaranteed_efg_loans
    loans.with_scheme('efg').guaranteed.where("maturity_date < ?", LoanAlerts::NotClosedGuaranteedLoanAlert.start_date)
  end

  def not_closed_sflg_and_legacy_sflg_loans
    loans.
      with_scheme('non_efg').
      guaranteed.
      where("maturity_date < ?", LoanAlerts::SFLGNotClosedLoanAlert.start_date)
  end

  def system_user
    @system_user ||= SystemUser.first
  end

end
