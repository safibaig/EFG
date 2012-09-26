class CfeUserLender
  def lending_limits
    LendingLimit.none
  end

  def loans
    Loan.scoped
  end

  def users
    CfeUser.scoped
  end

  def can_access_all_loan_schemes?
    true
  end
end
