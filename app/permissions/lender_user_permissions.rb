module LenderUserPermissions
  def can_create?(resource)
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
      SupportRequest,
      TransferredLoanEntry
    ].include?(resource)
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
