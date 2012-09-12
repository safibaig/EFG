require 'spec_helper'

describe SuperUserPermissions do
  include RefuteMacro

  let(:user) { FactoryGirl.build(:super_user) }

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
    it { refute user.can_view?(PremiumSchedule) }
    it { refute user.can_update?(PremiumSchedule) }
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

  context 'Loan::States' do
    it { refute user.can_view?(Loan::States) }
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
    it { refute user.can_create?(LenderAdmin) }
    it { refute user.can_update?(LenderAdmin) }
    it { refute user.can_view?(LenderAdmin) }
  end

  context 'CfeAdmins' do
    it { assert user.can_create?(CfeAdmin) }
    it { assert user.can_update?(CfeAdmin) }
    it { assert user.can_view?(CfeAdmin) }
  end

  context 'CfeUsers' do
    it { refute user.can_create?(CfeUser) }
    it { refute user.can_update?(CfeUser) }
    it { refute user.can_view?(CfeUser) }
  end

  context 'AuditorUsers' do
    it { refute user.can_create?(AuditorUser) }
    it { refute user.can_update?(AuditorUser) }
    it { refute user.can_view?(AuditorUser) }
  end

  context 'PremiumCollectorUsers' do
    it { refute user.can_create?(PremiumCollectorUser) }
    it { refute user.can_update?(PremiumCollectorUser) }
    it { refute user.can_view?(PremiumCollectorUser) }
  end

  context 'LenderUsers' do
    it { refute user.can_create?(LenderUser) }
    it { refute user.can_update?(LenderUser) }
    it { refute user.can_view?(LenderUser) }
  end

  context 'Lenders' do
    it { refute user.can_create?(Lender) }
    it { refute user.can_update?(Lender) }
    it { refute user.can_view?(Lender) }
  end
end
