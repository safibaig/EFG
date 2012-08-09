class PremiumCollectorLender
  def loan_allocations
    LoanAllocation.none
  end

  def loans
    Loan.none
  end

  def users
    PremiumCollectorUser.scoped
  end
end
