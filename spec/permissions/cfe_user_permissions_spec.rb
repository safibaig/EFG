require 'spec_helper'

describe CfeUserPermissions do
  include RefuteMacro
  include CfeUserPermissions

  context 'invoices' do
    it { assert can_view?(Invoice) }
    it { assert can_create?(Invoice) }
  end

  context 'recoveries' do
    it { refute can_create?(Recovery) }
  end

  context 'realisation statements' do
    it { assert can_view?(RealisationStatement) }
    it { assert can_create?(RealisationStatement) }
  end

  context 'remove guarantee' do
    it { assert can_view?(LoanRemoveGuarantee) }
    it { assert can_create?(LoanRemoveGuarantee) }
  end

  context 'loan eligibility checks' do
    it { refute can_create?(LoanEligibilityCheck) }
  end

  context 'state aid calculations' do
    it { refute can_update?(StateAidCalculation) }
  end

  context 'data protection declaration' do
    it { refute can_view?(DataProtectionDeclaration) }
  end

  context 'information declaration' do
    it { refute can_view?(InformationDeclaration) }
  end

  context 'state aid letters' do
    it { refute can_view?(StateAidLetter) }
  end

  context 'premium schedules' do
    it { refute can_view?(PremiumSchedule) }
    it { refute can_update?(PremiumSchedule) }
  end

  context 'Loan Offer' do
    it { refute can_create?(LoanOffer) }
  end

  context 'Loan Entry' do
    it { refute can_create?(LoanEntry) }
  end

  context 'Loan Cancel' do
    it { refute can_create?(LoanCancel) }
  end

  context 'Loan Demand to Borrower' do
    it { refute can_create?(LoanDemandToBorrower) }
  end

  context 'Loan Repay' do
    it { refute can_create?(LoanRepay) }
  end

  context 'Loan No Claim' do
    it { refute can_create?(LoanNoClaim) }
  end

  context 'Loan Demand Against Government' do
    it { refute can_create?(LoanDemandAgainstGovernment) }
  end

  context 'Loan Guarantee' do
    it { refute can_create?(LoanGuarantee) }
  end

  context 'loan changes' do
    it { refute can_view?(LoanChange) }
    it { refute can_create?(LoanChange) }
  end

  context 'loan alerts' do
    it { assert can_view?(LoanAlerts) }
  end

  context 'premium schedule report' do
    it { refute can_create?(PremiumScheduleReport) }
  end

  context 'Loan' do
    it { assert can_view?(Loan) }
  end

  context 'Loan::States' do
    it { assert can_view?(Loan::States) }
  end

  context 'Search' do
    it { assert can_create?(Search) }
  end
end
