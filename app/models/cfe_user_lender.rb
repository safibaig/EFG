class CfeUserLender
  def loan_allocations
    LoanAllocation.none
  end

  def loans
    Loan.scoped
  end

  def users
    CfeUser.scoped
  end
end
