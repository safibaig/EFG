require 'spec_helper'

describe CfeUserPermissions do
  include RefuteMacro
  include CfeUserPermissions

  context "invoices" do
    it "can view" do
      assert can_view?(Invoice)
    end

    it "can create" do
      assert can_create?(Invoice)
    end
  end

  context 'recoveries' do
    it 'cannot create' do
      refute can_create?(Recovery)
    end
  end

  context "realisation statements" do
    it "can view" do
      assert can_view?(RealisationStatement)
    end

    it "can create" do
      assert can_create?(RealisationStatement)
    end
  end

  context "remove guarantee" do
    it "can view" do
      assert can_view?(LoanRemoveGuarantee)
    end

    it "can create" do
      assert can_create?(LoanRemoveGuarantee)
    end
  end

  context "loan eligibility checks" do
    it "can't create" do
      refute can_create?(LoanEligibilityCheck)
    end
  end

  context "state aid calculations" do
    it "can update" do
      refute can_update?(StateAidCalculation)
    end
  end

  context "data protection declaration" do
    it "can view" do
      refute can_view?(DataProtectionDeclaration)
    end
  end

  context "information declaration" do
    it "can view" do
      refute can_view?(InformationDeclaration)
    end
  end

  context "state aid letters" do
    it "can view" do
      refute can_view?(StateAidLetter)
    end
  end

  context "premium schedules" do
    it "can view" do
      refute can_view?(PremiumSchedule)
    end

    it "can update" do
      refute can_update?(PremiumSchedule)
    end
  end

  context "Loan Offer" do
    it "can create" do
      refute can_create?(LoanOffer)
    end
  end

  context "Loan Entry" do
    it "can create" do
      refute can_create?(LoanEntry)
    end
  end

  context "Loan Cancel" do
    it "can create" do
      refute can_create?(LoanCancel)
    end
  end

  context "Loan Demand to Borrower" do
    it "can create" do
      refute can_create?(LoanDemandToBorrower)
    end
  end

  context "Loan Repay" do
    it "can create" do
      refute can_create?(LoanRepay)
    end
  end

  context "Loan No Claim" do
    it "can create" do
      refute can_create?(LoanNoClaim)
    end
  end

  context "Loan Demand Against Government" do
    it "can create" do
      refute can_create?(LoanDemandAgainstGovernment)
    end
  end

  context "Loan Guarantee" do
    it "can create" do
      refute can_create?(LoanGuarantee)
    end
  end

  context 'loan changes' do
    it 'can view' do
      refute can_view?(LoanChange)
    end

    it 'cannot create' do
      refute can_create?(LoanChange)
    end
  end

  context 'loan alerts' do
    it 'can view' do
      assert can_view?(LoanAlerts)
    end
  end

  context 'premium schedule report' do
    it 'cannot create' do
      refute can_create?(PremiumScheduleReport)
    end
  end

  context 'Loan' do
    it 'can view' do
      assert can_view?(Loan)
    end
  end

  context 'Loan::States' do
    it 'can view' do
      assert can_view?(Loan::States)
    end
  end

  context 'Search' do
    it 'can view' do
      assert can_view?(Search)
    end
  end
end
