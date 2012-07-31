require 'spec_helper'

describe PremiumScheduleCollectorUser do
  include RefuteMacro
  include PremiumScheduleCollectorUserPermissions

  context 'invoices' do
    it 'cannot view' do
      refute can_view?(Invoice)
    end

    it 'cannot create' do
      refute can_create?(Invoice)
    end
  end

  context 'recoveries' do
    it 'cannot create' do
      refute can_create?(Recovery)
    end
  end

  context 'realisation statements' do
    it 'cannot view' do
      refute can_view?(RealisationStatement)
    end

    it 'cannot create' do
      refute can_create?(RealisationStatement)
    end
  end

  context 'remove guarantee' do
    it 'cannot view' do
      refute can_view?(LoanRemoveGuarantee)
    end

    it 'cannot create' do
      refute can_create?(LoanRemoveGuarantee)
    end
  end

  context 'loan eligibility checks' do
    it 'cannot create' do
      refute can_create?(LoanEligibilityCheck)
    end
  end

  context 'state aid calculations' do
    it 'cannot update' do
      refute can_update?(StateAidCalculation)
    end
  end

  context 'data protection declaration' do
    it 'cannot view' do
      refute can_view?(DataProtectionDeclaration)
    end
  end

  context 'information declaration' do
    it 'cannot view' do
      refute can_view?(InformationDeclaration)
    end
  end

  context 'state aid letters' do
    it 'cannot view' do
      refute can_view?(StateAidLetter)
    end
  end

  context 'premium schedules' do
    it 'cannot view' do
      refute can_view?(PremiumSchedule)
    end

    it 'cannot update' do
      refute can_update?(PremiumSchedule)
    end
  end

  context 'Loan Offer' do
    it 'cannot create' do
      refute can_create?(LoanOffer)
    end
  end

  context 'Loan Entry' do
    it 'cannot create' do
      refute can_create?(LoanEntry)
    end
  end

  context 'Loan Cancel' do
    it 'cannot create' do
      refute can_create?(LoanCancel)
    end
  end

  context 'Loan Demand to Borrower' do
    it 'cannot create' do
      refute can_create?(LoanDemandToBorrower)
    end
  end

  context 'Loan Repay' do
    it 'cannot create' do
      refute can_create?(LoanRepay)
    end
  end

  context 'Loan No Claim' do
    it 'cannot create' do
      refute can_create?(LoanNoClaim)
    end
  end

  context 'Loan Demand Against Government' do
    it 'cannot create' do
      refute can_create?(LoanDemandAgainstGovernment)
    end
  end

  context 'Loan Guarantee' do
    it 'cannot create' do
      refute can_create?(LoanGuarantee)
    end
  end

  context 'loan changes' do
    it 'cannot create' do
      refute can_create?(LoanChange)
    end
  end

  context 'premium schedule report' do
    it 'can create' do
      assert can_create?(PremiumScheduleReport)
    end
  end
end
