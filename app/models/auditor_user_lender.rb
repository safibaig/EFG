class AuditorUserLender
  def loans
    Loan.scoped
  end

  def users
    AuditorUser.scoped
  end
end
