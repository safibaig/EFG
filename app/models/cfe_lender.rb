class CfeLender
  def loan_allocations
    LoanAllocation.where('1=0')
  end

  def loans
    Loan.scoped
  end
end
