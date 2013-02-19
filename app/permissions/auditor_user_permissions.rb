module AuditorUserPermissions
  def can_create?(resource)
    [
      AskCfe,
      LoanReport,
      LoanAuditReport
    ].include?(resource)
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    false
  end

  def can_enable?(resource)
    can_update?(resource)
  end

  def can_disable?(resource)
    can_update?(resource)
  end

  def can_unlock?(resource)
    can_update?(resource)
  end

  def can_view?(resource)
    [Loan, LoanChange, LoanStates, Search].include?(resource)
  end
end
