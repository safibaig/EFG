class PremiumScheduleCollectorLender
  def loan_allocations
    LoanAllocation.none
  end

  def loans
    Loan.none
  end

  def users
    PremiumScheduleCollectorUser.scoped
  end
end
