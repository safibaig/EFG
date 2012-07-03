class CfeLender
  def loan_allocations
    LoanAllocation.none
  end

  def loans
    Loan.scoped
  end
end
