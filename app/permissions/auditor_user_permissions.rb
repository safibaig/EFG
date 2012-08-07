module AuditorUserPermissions
  def can_create?(resource)
    false
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    [Loan, LoanChange, Loan::States, Search].include?(resource)
  end
end
