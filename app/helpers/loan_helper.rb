module LoanHelper

  def loan_title(title, loan)
    title << " for #{loan.reference}" if loan.reference.present?
    title
  end

  def loan_listing_title(state, scheme = nil)
    title = "Loans: #{state.titleize}"
    title += " (#{scheme.titleize})" if scheme
    title
  end

  def loan_business_name(loan)
    loan.business_name.present? ? loan.business_name : '<not assigned>'
  end

  def loan_summary(loan, &block)
    insert = block_given? ? capture(&block) : nil
    render('loans/summary', loan: loan, insert: insert)
  end

  def link_to_premium_schedule(loan)
    return unless current_user.can_view?(PremiumSchedule)

    if loan.premium_schedule
      link_to('Generate Premium Schedule', loan_premium_schedule_path(loan), class: 'btn btn-info')
    end
  end

  def link_to_loan_entry(loan)
    if loan.created_from_transfer?
      path = new_loan_transferred_entry_path(loan)
      permission_class = TransferredLoanEntry
    else
      path = new_loan_entry_path(loan)
      permission_class = LoanEntry
    end
    link_to('Loan Entry', path, class: 'btn btn-primary') if current_user.can_create?(permission_class)
  end

  def for_loan_in_categories(loan, *loan_category_ids)
    yield if block_given? && loan_category_ids.include?(loan.loan_category_id)
  end

  def loan_state_history_includes?(loan, *states)
    (loan.state_history & states).size > 0
  end

  def loan_state_options(states)
    states.map { |state| [state.humanize, state] }.unshift(['All states', nil])
  end

  def loan_ineligible?(loan)
    [Loan::Rejected, Loan::Incomplete].include?(loan.state) && loan.ineligibility_reasons.present?
  end

end
