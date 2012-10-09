class LoanTerm

  DEFAULT_MIN_LOAN_TERM_MONTHS = 3

  DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG = 24

  DEFAULT_MAX_LOAN_TERM_MONTHS = 120

  attr_reader :loan, :loan_category

  def initialize(loan)
    @loan = loan
    @loan_category = LoanCategory.find(loan.loan_category_id)
  end

  def min_months
    return 0 if loan.created_from_transfer?
    return loan_category.min_loan_term if loan_category
    return DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG if loan.sflg? || loan.legacy_loan?
    DEFAULT_MIN_LOAN_TERM_MONTHS
  end

  def max_months
    loan_category ? loan_category.max_loan_term : DEFAULT_MAX_LOAN_TERM_MONTHS
  end

  def earliest_start_date
    Date.today.advance(months: min_months)
  end

  def latest_end_date
    Date.today.advance(months: max_months)
  end

end
