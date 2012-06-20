class UtilisationPresenter

  def initialize(lender)
    @loan_allocations = lender.loan_allocations.where("allocation > 0").order("starts_on DESC")
  end

  def each_loan_allocation
    @loan_allocations.each_with_index do |loan_allocation, index|
      yield LoanAllocationUtilisationPresenter.new(loan_allocation), index
    end
  end

  def has_allocations?
    !@loan_allocations.empty?
  end

end
