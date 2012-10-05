class LoanTerm

  MIN_LOAN_TERM_MONTHS = 3

  MIN_LOAN_TERM_MONTHS_SFLG = 24

  MAX_LOAN_TERM_MONTHS = 120

  attr_reader :loan, :loan_category

  def initialize(loan)
    @loan = loan
    @loan_category = LoanCategory.find(loan.loan_category_id)
  end

  def min_months
    if loan.created_from_transfer?
      0
    elsif loan_category
      loan_category.min_loan_term
    elsif loan.sflg? || loan.legacy_loan?
      MIN_LOAN_TERM_MONTHS_SFLG
    else
      MIN_LOAN_TERM_MONTHS
    end
  end

  def max_months
    if loan_category
      loan_category.max_loan_term
    else
      MAX_LOAN_TERM_MONTHS
    end
  end

end
