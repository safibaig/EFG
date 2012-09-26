class PremiumCollectorLender
  def lending_limits
    LendingLimit.none
  end

  def loans
    Loan.none
  end

  def users
    PremiumCollectorUser.scoped
  end

  def can_access_all_loan_schemes?
    true
  end
end
