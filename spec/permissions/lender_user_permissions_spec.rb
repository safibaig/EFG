require 'spec_helper'

describe LenderUserPermissions do
  include RefuteMacro
  include LenderUserPermissions

  context 'invoices' do
    it { refute can_view?(Invoice) }
    it { refute can_create?(Invoice) }
  end

  context 'recoveries' do
    it { assert can_create?(Recovery) }
  end

  context 'realisation statements' do
    it { refute can_view?(RealisationStatement) }
    it { refute can_create?(RealisationStatement) }
  end

  context 'remove guarantee' do
    it { refute can_view?(LoanRemoveGuarantee) }
    it { refute can_create?(LoanRemoveGuarantee) }
  end

  context 'loan eligibility checks' do
    it { assert can_create?(LoanEligibilityCheck) }
  end

  context 'state aid calculations' do
    it { assert can_update?(StateAidCalculation) }
  end

  context 'data protection declaration' do
    it { assert can_view?(DataProtectionDeclaration) }
  end

  context 'information declaration' do
    it { assert can_view?(InformationDeclaration) }
  end

  context 'state aid letters' do
    it { assert can_view?(StateAidLetter) }
  end

  context 'premium schedules' do
    it { assert can_view?(PremiumSchedule) }
    it { assert can_update?(PremiumSchedule) }
  end

  context 'Loan Offer' do
    it { assert can_create?(LoanOffer) }
  end

  context 'Loan Entry' do
    it { assert can_create?(LoanEntry) }
  end

  context 'Loan Cancel' do
    it { assert can_create?(LoanCancel) }
  end

  context 'Loan Demand to Borrower' do
    it { assert can_create?(LoanDemandToBorrower) }
  end

  context 'Loan Repay' do
    it { assert can_create?(LoanRepay) }
  end

  context 'Loan No Claim' do
    it { assert can_create?(LoanNoClaim) }
  end

  context 'Loan Demand Against Government' do
    it { assert can_create?(LoanDemandAgainstGovernment) }
  end

  context 'Loan Guarantee' do
    it { assert can_create?(LoanGuarantee) }
  end

  context 'loan changes' do
    it { assert can_view?(LoanChange) }
    it { assert can_create?(LoanChange) }
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
    it { assert can_view?(Search) }
  end
end
