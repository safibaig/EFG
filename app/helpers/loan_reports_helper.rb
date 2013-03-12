module LoanReportsHelper

  LOAN_SOURCE_NAMES = {
    'New Scheme'    => Loan::SFLG_SOURCE,
    'Legacy Scheme' => Loan::LEGACY_SFLG_SOURCE
  }

  LOAN_SCHEME_NAMES = {
    'SFLG Only' => Loan::SFLG_SCHEME,
    'EFG Only'  => Loan::EFG_SCHEME
  }

  def loan_report_source_options
    LOAN_SOURCE_NAMES.to_a
  end

  def loan_report_scheme_options
    LOAN_SCHEME_NAMES.to_a
  end

  def loan_source_name(sources)
    sources.collect { |source| LOAN_SOURCE_NAMES.invert[source] }.join(', ')
  end

  def loan_scheme_name(scheme)
    LOAN_SCHEME_NAMES.invert[scheme]
  end

  def loan_report_organisation_names(lender_ids)
    Lender.find(lender_ids).collect(&:name).join(' / ')
  end

  def loan_report_states(states)
    states.is_a?(Array) && states.collect(&:humanize).join(', ')
  end
end
