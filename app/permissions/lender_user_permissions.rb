module LenderUserPermissions
  def can_create?(resource)
    if resource == AskAnExpert
      !expert?
    elsif resource == AskCfe
      expert?
    else
      [
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
        LoanTransfer::LegacySflg,
        LoanTransfer::Sflg,
        Recovery,
        StateAidCalculation,
        TransferredLoanEntry
      ].include?(resource)
    end
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    [
      PremiumSchedule,
      StateAidCalculation
    ].include?(resource)
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
