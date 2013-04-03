module LenderUserPermissions
  def can_create?(resource)
    if resource == AskAnExpert
      !expert?
    elsif resource == AskCfe
      expert?
    else
      [
        AgreedDraw,
        DataCorrection,
        LoanCancel,
        LoanChange,
        LoanDemandAgainstGovernment,
        LoanDemandToBorrower,
        LoanEligibilityCheck,
        LoanEntry,
        LoanGuarantee,
        LoanNoClaim,
        LoanOffer,
        LoanRepay,
        LoanReport,
        LoanSatisfyLenderDemand,
        LoanTransfer::LegacySflg,
        LoanTransfer::Sflg,
        Recovery,
        PremiumSchedule,
        TransferredLoanEntry
      ].include?(resource)
    end
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    [
      PremiumSchedule
    ].include?(resource)
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
      DataProtectionDeclaration,
      InformationDeclaration,
      Loan,
      LoanStates,
      LoanAlerts,
      LoanChange,
      LoanModification,
      PremiumSchedule,
      Search,
      StateAidLetter
    ].include?(resource)
  end
end
