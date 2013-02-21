module CfeUserPermissions
  def can_create?(resource)
    [
      Invoice,
      LoanRemoveGuarantee,
      RealisationStatement,
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
    [
      Invoice,
      Loan,
      LoanAlerts,
      LoanChange,
      LoanRemoveGuarantee,
      LoanStates,
      LoanModification,
      RealisationStatement,
      Search
    ].include?(resource)
  end
end
