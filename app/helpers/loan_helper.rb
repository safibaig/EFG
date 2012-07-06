module LoanHelper

  def loan_title(title, loan)
    title << " for #{loan.reference}" if loan.reference.present?
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
    premium_schedule = loan.premium_schedule

    if premium_schedule && current_user.can_view?(premium_schedule)
      link_to('Generate Premium Schedule', loan_premium_schedule_path(loan), class: 'btn btn-info')
    end
  end
end
