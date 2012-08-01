module LoanReportsHelper

  def loan_report_state_options
    LoanReport::ALLOWED_LOAN_STATES.map { |state| [state.humanize, state] }
  end

  def loan_report_source_options
    [ ['New Scheme', Loan::SFLG_SOURCE], ['Legacy Scheme', Loan::LEGACY_SFLG_SOURCE] ]
  end

  def loan_report_scheme_options
    [ ['All'], ['SFLG Only', Loan::SFLG_SCHEME], ['EFG Only', Loan::EFG_SCHEME] ]
  end

  def loan_report_lender_options
    current_user.lenders.map { |lender| [ lender.name, lender.id ] }
  end

end
