module LenderUserPermissions
  def can_create?(resource)
    ![
      Invoice,
      LoanRemoveGuarantee,
      RealisationStatement,
      PremiumScheduleReport
    ].include?(resource)
  end

  def can_update?(resource)
    true
  end

  def can_view?(resource)
    ![Invoice, LoanRemoveGuarantee, RealisationStatement].include?(resource)
  end
end
