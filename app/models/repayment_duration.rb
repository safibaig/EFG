class RepaymentDuration

  DEFAULT_MIN_LOAN_TERM_MONTHS = 3

  DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG = 24

  DEFAULT_MAX_LOAN_TERM_MONTHS = 120

  attr_reader :loan, :loan_category

  delegate :maturity_date, to: :loan

  def initialize(loan)
    @loan = loan
    @loan_category = LoanCategory.find(loan.loan_category_id)
  end

  def min_months
    return 0 if loan.created_from_transfer?
    return loan_category.min_repayment_duration if loan_category
    return DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG if loan.sflg? || loan.legacy_loan?
    DEFAULT_MIN_LOAN_TERM_MONTHS
  end

  def max_months
    loan_category ? loan_category.max_repayment_duration : DEFAULT_MAX_LOAN_TERM_MONTHS
  end

  def earliest_start_date
    Date.today.advance(months: min_months)
  end

  def latest_end_date
    Date.today.advance(months: max_months)
  end

  def months_between_draw_date_and_maturity_date
    month_count         = 1 # count the initial draw month
    comparison_date     = initial_draw_date = loan.initial_draw_change.date_of_change
    comparison_end_date = maturity_date.prev_month

    # count the number of months between initial draw date and one month prior to maturity date
    until comparison_date.year == comparison_end_date.year && comparison_date.month == comparison_end_date.month
      comparison_date = comparison_date.next_month
      month_count += 1
    end

    # only count the last month if its maturity day number is after the initial draw day number
    # (e.g. draw day 20th, maturity day 21st)
    if maturity_date.day > initial_draw_date.day
      month_count += 1
    end

    month_count
  end

end
