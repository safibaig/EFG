require 'spec_helper'

describe CfeAdminPermissions do
  include RefuteMacro

  let(:user) { FactoryGirl.build(:cfe_admin) }

  context 'invoices' do
    it { refute user.can_view?(Invoice) }
    it { refute user.can_create?(Invoice) }
  end

  context 'recoveries' do
    it { refute user.can_create?(Recovery) }
  end

  context 'realisation statements' do
    it { refute user.can_view?(RealisationStatement) }
    it { refute user.can_create?(RealisationStatement) }
  end

  context 'remove guarantee' do
    it { refute user.can_view?(LoanRemoveGuarantee) }
    it { refute user.can_create?(LoanRemoveGuarantee) }
  end

  context 'loan eligibility checks' do
    it { refute user.can_create?(LoanEligibilityCheck) }
  end

  context 'state aid calculations' do
    it { refute user.can_update?(StateAidCalculation) }
  end

  context 'data protection declaration' do
    it { refute user.can_view?(DataProtectionDeclaration) }
  end

  context 'information declaration' do
    it { refute user.can_view?(InformationDeclaration) }
  end

  context 'state aid letters' do
    it { refute user.can_view?(StateAidLetter) }
  end

  context 'premium schedules' do
    it { refute user.can_view?(PremiumScheduleGenerator) }
    it { refute user.can_update?(PremiumScheduleGenerator) }
  end

  context 'Loan Offer' do
    it { refute user.can_create?(LoanOffer) }
  end

  context 'Loan Entry' do
    it { refute user.can_create?(LoanEntry) }
  end

  context 'Loan Cancel' do
    it { refute user.can_create?(LoanCancel) }
  end

  context 'Loan Demand to Borrower' do
    it { refute user.can_create?(LoanDemandToBorrower) }
  end

  context 'Loan Repay' do
    it { refute user.can_create?(LoanRepay) }
  end

  context 'Loan No Claim' do
    it { refute user.can_create?(LoanNoClaim) }
  end

  context 'Loan Demand Against Government' do
    it { refute user.can_create?(LoanDemandAgainstGovernment) }
  end

  context 'Loan Guarantee' do
    it { refute user.can_create?(LoanGuarantee) }
  end

  context 'loan changes' do
    it { refute user.can_view?(LoanChange) }
    it { refute user.can_create?(LoanChange) }
  end

  context 'loan alerts' do
    it { refute user.can_view?(LoanAlerts) }
  end

  context 'premium schedule report' do
    it { refute user.can_create?(PremiumScheduleReport) }
  end

  context 'loan report' do
    it { refute user.can_create?(LoanReport) }
    it { refute user.can_update?(LoanReport) }
    it { refute user.can_view?(LoanReport) }
  end

  context 'LoanAuditReport' do
    it { refute user.can_create?(LoanAuditReport) }
    it { refute user.can_update?(LoanAuditReport) }
    it { refute user.can_view?(LoanAuditReport) }
  end

  context 'Loan' do
    it { refute user.can_view?(Loan) }
  end

  context 'LoanStates' do
    it { refute user.can_view?(LoanStates) }
  end

  context 'Search' do
    it { refute user.can_view?(Search) }
  end

  context 'TransferredLoanEntry' do
    it { refute user.can_create?(TransferredLoanEntry) }
  end

  context 'LoanTransfer::LegacySflg' do
    it { refute user.can_create?(LoanTransfer::LegacySflg) }
  end

  context 'LoanTransfer::Sflg' do
    it { refute user.can_create?(LoanTransfer::Sflg) }
  end

  context 'StateAidCalculation' do
    it { refute user.can_create?(StateAidCalculation) }
  end

  context 'LenderAdmins' do
    it { assert user.can_create?(LenderAdmin) }
    it { assert user.can_update?(LenderAdmin) }
    it { assert user.can_view?(LenderAdmin) }
    it { assert user.can_unlock?(LenderAdmin) }
    it { assert user.can_enable?(LenderAdmin) }
    it { assert user.can_disable?(LenderAdmin) }
  end

  context 'CfeAdmins' do
    it { refute user.can_create?(CfeAdmin) }
    it { refute user.can_update?(CfeAdmin) }
    it { refute user.can_view?(CfeAdmin) }
    it { refute user.can_unlock?(CfeAdmin) }
    it { refute user.can_enable?(CfeAdmin) }
    it { refute user.can_disable?(CfeAdmin) }
  end

  context 'CfeUsers' do
    it { assert user.can_create?(CfeUser) }
    it { assert user.can_update?(CfeUser) }
    it { assert user.can_view?(CfeUser) }
    it { assert user.can_unlock?(CfeUser) }
    it { assert user.can_enable?(CfeUser) }
    it { assert user.can_disable?(CfeUser) }
  end

  context 'AuditorUsers' do
    it { assert user.can_create?(AuditorUser) }
    it { assert user.can_update?(AuditorUser) }
    it { assert user.can_view?(AuditorUser) }
    it { assert user.can_unlock?(AuditorUser) }
    it { assert user.can_enable?(AuditorUser) }
    it { assert user.can_disable?(AuditorUser) }
  end

  context 'PremiumCollectorUsers' do
    it { assert user.can_create?(PremiumCollectorUser) }
    it { assert user.can_update?(PremiumCollectorUser) }
    it { assert user.can_view?(PremiumCollectorUser) }
    it { assert user.can_unlock?(PremiumCollectorUser) }
    it { assert user.can_enable?(PremiumCollectorUser) }
    it { assert user.can_disable?(PremiumCollectorUser) }
  end

  context 'LenderUsers' do
    it { refute user.can_create?(LenderUser) }
    it { refute user.can_update?(LenderUser) }
    it { refute user.can_view?(LenderUser) }
    it { refute user.can_unlock?(LenderUser) }
    it { refute user.can_enable?(LenderUser) }
    it { refute user.can_disable?(LenderUser) }
  end

  context 'Lenders' do
    it { assert user.can_create?(Lender) }
    it { assert user.can_update?(Lender) }
    it { assert user.can_view?(Lender) }
  end

  context 'LendingLimits' do
    it { assert user.can_create?(LendingLimit) }
    it { assert user.can_update?(LendingLimit) }
    it { assert user.can_view?(LendingLimit) }
  end

  context 'DataCorrection' do
    it { refute user.can_create?(DataCorrection) }
    it { refute user.can_update?(DataCorrection) }
    it { refute user.can_view?(DataCorrection) }
  end

  context 'LoanModification' do
    it { refute user.can_create?(LoanModification) }
    it { refute user.can_update?(LoanModification) }
    it { refute user.can_view?(LoanModification) }
  end

  context 'AskCfe' do
    it { refute user.can_create?(AskCfe) }
    it { refute user.can_update?(AskCfe) }
    it { refute user.can_view?(AskCfe) }
  end

  context 'AskAnExpert' do
    it { refute user.can_create?(AskAnExpert) }
    it { refute user.can_update?(AskAnExpert) }
    it { refute user.can_view?(AskAnExpert) }
  end

  context 'Expert' do
    it { refute user.can_create?(Expert) }
    it { refute user.can_destroy?(Expert) }
    it { refute user.can_update?(Expert) }
    it { assert user.can_view?(Expert) }
  end

  context 'Phases' do
    it { assert user.can_create?(Phase) }
    it { assert user.can_update?(Phase) }
    it { assert user.can_view?(Phase) }
  end
end
