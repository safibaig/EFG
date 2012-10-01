module LoanAutoUpdater
  extend self
  extend LoanAlerts

  def cancel_not_progressed_loans!
    Loan.not_progressed.where("updated_at < ?", not_progressed_start_date).update_all(state: Loan::AutoCancelled)
  end

  def cancel_not_drawn_loans!
    Loan.offered.where("facility_letter_date < ?", not_drawn_start_date).update_all(state: Loan::AutoCancelled)
  end

  def remove_guarantee_from_not_demanded_loans!
    Loan.with_scheme('non_efg').lender_demanded.where("borrower_demanded_on < ?", demanded_start_date).update_all(state: Loan::AutoRemoved)
  end

  def remove_assumed_repaid_loans!
    # not yet guaranteed EFG loans
    Loan.
      with_scheme('efg').
      where(state: [Loan::Incomplete, Loan::Completed, Loan::Offered]).
      where("maturity_date < ?", assumed_repaid_offered_start_date).update_all(state: Loan::AutoRemoved)

    # guaranteed EFG loans
    Loan.
      with_scheme('efg').
      guaranteed.
      where("maturity_date < ?", assumed_repaid_guaranteed_start_date).
      update_all(state: Loan::AutoRemoved)

    # SFLG and Legacy SFLG loans in any state
    Loan.
      with_scheme('non_efg').
      where("maturity_date < ?", sflg_assumed_repaid_start_date).
      update_all(state: Loan::AutoRemoved)
  end

end
