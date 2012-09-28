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

  def can_view?(resource)
    [
      Invoice,
      Loan,
      LoanAlerts,
      LoanChange,
      LoanRemoveGuarantee,
      LoanStates,
      RealisationStatement,
      Search
    ].include?(resource)
  end
end
