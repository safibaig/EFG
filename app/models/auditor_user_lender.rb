class AuditorUserLender
  def loans
    Loan.scoped
  end

  def users
    AuditorUser.scoped
  end

  def can_access_all_loan_schemes?
    true
  end
end
