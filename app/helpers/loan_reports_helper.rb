module LoanReportsHelper

  def loan_report_state_options
    LoanReport::ALLOWED_LOAN_STATES.map { |state| [state.humanize, state] }
  end

  def loan_report_source_options
    [ ['New Scheme', Loan::SFLG_SOURCE], ['Legacy Scheme', Loan::LEGACY_SFLG_SOURCE] ]
  end

  def loan_report_scheme_options
    [ ['SFLG Only', Loan::SFLG_SCHEME], ['EFG Only', Loan::EFG_SCHEME] ]
  end

  def loan_report_lender_field(form_builder)
    if current_user.lenders.count == 1
      hidden_field_tag 'loan_report[lender_ids][]', current_lender.id
    else
      form_builder.input :lender_ids, as: :select, collection: loan_report_lender_options, input_html: { multiple: true }
    end
  end

  def loan_report_lender_options
    current_user.lenders.map { |lender| [ lender.name, lender.id ] }
  end

  def loan_report_created_by_field(form_builder)
    if current_user.is_a?(LenderUser)
      form_builder.input :created_by_id, as: :select, collection: current_lender.users, prompt: 'All'
    end
  end

end
