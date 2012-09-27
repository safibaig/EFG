class LoanStates

  def initialize(lender)
    @lender = lender
  end

  def states
    Loan::States.collect { |loan_state|
      loans_grouped_by_state.detect { |loan| loan.state.to_s == loan_state.to_s }
    }.compact
  end

  private

  def loans_grouped_by_state
    @loans_grouped_by_state ||= @lender.loans.select(select_options).group(:state)
  end

  def select_options
    [
      "state",
      "count(IF(loan_source = 'L' AND loan_scheme = 'S', 1, NULL)) as legacy_sflg_loans_count",
      "count(IF(loan_source = 'S' AND loan_scheme = 'S', 1, NULL)) as sflg_loans_count",
      "count(IF(loan_scheme = 'E', 1, NULL)) as efg_loans_count",
      "count(state) AS total_loans"
    ].join(', ')
  end

end

