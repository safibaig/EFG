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

  def premium_schedule_link(loan)
    link_to('Generate Premium Schedule', loan_premium_schedule_path(loan), class: 'btn btn-info') if loan.premium_schedule
  end
end
