module LoanReportsHelper
  def loan_report_organisation_names(lender_ids)
    Lender.find(lender_ids).collect(&:name).join(' / ')
  end

  def loan_report_states(states)
    states.is_a?(Array) && states.collect(&:humanize).join(', ')
  end
end
