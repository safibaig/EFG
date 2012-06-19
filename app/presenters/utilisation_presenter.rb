class UtilisationPresenter

  def initialize(lender)
    @loan_allocations = lender.loan_allocations.where("allocation > 0").includes(:completed_loans).order("starts_on DESC").limit(4)
  end

  def each_loan_allocation
    @loan_allocations.each_with_index do |loan_allocation, index|
      yield LoanAllocationUtilisationPresenter.new(loan_allocation, loan_allocation.completed_loans), index
    end
  end

  def has_allocations?
    !@loan_allocations.empty?
  end

end
