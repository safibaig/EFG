module LenderUserPermissions
  def can_create?(resource)
    [
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
      LoanTransfer::LegacySflg,
      LoanTransfer::Sflg,
      Recovery,
      StateAidCalculation,
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
      LoanAlerts,
      LoanChange,
      Loan::States,
      PremiumSchedule,
      Search,
      StateAidLetter
    ].include?(resource)
  end
end
