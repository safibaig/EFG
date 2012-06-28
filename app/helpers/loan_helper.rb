module LoanHelper

  def loan_title(title, loan)
    title << " for #{loan.reference}" if loan.reference.present?
    title
  end

  def loan_business_name(loan)
    loan.business_name.present? ? loan.business_name : '<not assigned>'
  end

end
