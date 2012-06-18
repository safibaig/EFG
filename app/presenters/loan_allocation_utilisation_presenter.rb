class LoanAllocationUtilisationPresenter

  def initialize(loan_allocation, loans)
    @loan_allocation = loan_allocation
    @loans = loans
  end

  def group_header(index)
    if index == 1
      '<h3 class="allocation_divider">Previous Years</h3>'
    elsif index == 0
      '<h3 class="allocation_divider">Current Year</h3>'
    end
  end

  def title
    start_date = @loan_allocation.starts_on.strftime('%B %Y')
    end_date = @loan_allocation.ends_on.strftime('%B %Y')
    [start_date, end_date].join(' - ')
  end

  def chart_colour
    if usage_percentage.to_f > 85.0
      "#ff0000"
    elsif usage_percentage.to_f > 50.0
      "#fff000"
    else
      "#00c000"
    end
  end

  def total_allocation
    @total_allocation ||= @loan_allocation.allocation
  end

  def usage_amount
    @allocation_usage_amount ||= allocation_has_loans? ? @loans.sum(&:amount) : Money.new(0)
  end

  def usage_percentage
    if allocation_has_loans?
      percentage = (@loans.sum(&:amount) / total_allocation) * 100
      sprintf("%03.2f", percentage)
    else
      0
    end
  end

  private

  def allocation_has_loans?
    @loans.present?
  end

end
