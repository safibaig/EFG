require 'spec_helper'

describe Loan do
  let(:loan) { FactoryGirl.build(:loan) }

  describe 'validations' do
    it 'has a valid Factory' do
      loan.should be_valid
    end

    it 'requires a lender' do
      loan.lender = nil
      loan.should_not be_valid
    end

    it 'requires a state' do
      loan.state = nil
      loan.should_not be_valid
    end

    it 'requires a known state' do
      loan.state = 'not-a-known-state-yo'
      loan.should_not be_valid
    end

    it 'requires a creator' do
      loan.created_by_id = nil
      loan.should_not be_valid
    end

    it 'requires a modifier' do
      loan.modified_by_id = nil
      loan.should_not be_valid
    end
  end

  describe ".last_updated_between scope" do
    let!(:loan1) { FactoryGirl.create(:loan, updated_at: 3.days.ago) }
    let!(:loan2) { FactoryGirl.create(:loan, updated_at: 1.day.ago) }

    it "returns loans last updated between the specified dates" do
      Loan.last_updated_between(2.days.ago, 1.day.ago).should == [loan2]
    end
  end

  describe ".not_progressed scope" do
    let!(:loan1) { FactoryGirl.create(:loan, :eligible) }
    let!(:loan2) { FactoryGirl.create(:loan, :completed) }
    let!(:loan3) { FactoryGirl.create(:loan, :incomplete) }
    let!(:loan4) { FactoryGirl.create(:loan, :offered) }

    it "returns loans with Eligible, Complete or Incomplete state" do
      result = Loan.not_progressed

      result.should include(loan1)
      result.should include(loan2)
      result.should include(loan3)
      result.should_not include(loan4)
    end
  end

  describe ".by_reference scope" do
    before(:each) do
      LoanReference.stub(:generate).and_return("ABC123", "ABC12345")
    end

    let!(:loan1) { FactoryGirl.create(:loan) }
    let!(:loan2) { FactoryGirl.create(:loan) }

    it "returns loans that partially or completely match the specified reference" do
      Loan.by_reference("ABC123").should == [loan1, loan2]
    end
  end

  describe "#state_aid_calculation" do

    let!(:loan) { FactoryGirl.create(:loan) }

    let!(:state_aid_calculation1) { FactoryGirl.create(:state_aid_calculation, loan: loan) }

    let!(:state_aid_calculation2) { FactoryGirl.create(:state_aid_calculation, loan: loan) }

    it "returns the most recent state aid calculation record" do
      loan.state_aid_calculation.should == state_aid_calculation2
    end
  end

  describe '#repayment_duration / #repayment_duration=' do
    let(:loan) { Loan.new }

    it 'conforms to the MonthDuration interface' do
      loan[:repayment_duration] = 18
      loan.repayment_duration.should == MonthDuration.new(18)
    end

    it 'converts year/months hash to months' do
      loan.repayment_duration = { years: 1, months: 6 }
      loan.repayment_duration.should == MonthDuration.new(18)
    end

    it 'does not convert blank values to zero' do
      loan.repayment_duration = { years: '', months: '' }
      loan.repayment_duration.should be_nil
    end
  end

  describe "#eligibility_check" do
    it "should instantiate and return an EligibiltyCheck" do
      loan = FactoryGirl.build(:loan)
      result = double(EligibilityCheck)
      EligibilityCheck.should_receive(:new).with(loan).and_return(result)

      loan.eligibility_check.should == result
    end
  end

  describe "#state_aid" do
    it "should return a EUR money object" do
      loan = FactoryGirl.build(:loan, state_aid: '100.00')
      loan.state_aid.should == Money.new(100_00, 'EUR')
    end

    it "return nil if not set" do
      loan = FactoryGirl.build(:loan, state_aid: '')
      loan.state_aid.should be_nil
    end
  end

  describe "#premium_schedule" do
    it "should return a PremiumSchedule for the loan" do
      loan = FactoryGirl.build(:loan)
      loan.state_aid_calculations.build

      loan.premium_schedule.should be_instance_of(PremiumSchedule)
      loan.premium_schedule.loan.should == loan
    end

    it "should return nil if it doesn't have a state aid calculation" do
      loan = FactoryGirl.build(:loan)
      loan.premium_schedule.should be_nil
    end
  end

  describe "reference" do
    let(:loan) {
      loan = FactoryGirl.build(:loan)
      loan.reference = nil
      loan
    }

    it "should be generated when loan is created" do
      loan.reference.should be_nil

      loan.save!

      loan.reference.should be_instance_of(String)
    end

    it "should be unique" do
      FactoryGirl.create(:loan, reference: 'ABC234')
      FactoryGirl.create(:loan, reference: 'DEF456')
      LoanReference.stub(:generate).and_return('ABC234', 'DEF456', 'GHF789')

      loan.save!

      loan.reference.should == 'GHF789'
    end

    it "should not be generated if already assigned" do
      loan.reference = "custom-reference"
      loan.save!
      loan.reload.reference.should == 'custom-reference'
    end
  end

  describe "#already_transferred" do
    it "returns true when a loan with the next incremented loan reference exists" do
      FactoryGirl.create(:loan, reference: 'Q9HTDF7-02')

      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should be_already_transferred
    end

    it "returns false when loan with next incremented loan reference does not exist" do
      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should_not be_already_transferred
    end

    it "returns false when loan has no reference" do
      Loan.new.should_not be_already_transferred
    end
  end

  describe "#created_from_transfer?" do
    it "returns true when a loan has been transferred from another loan" do
      loan = FactoryGirl.build(:loan, reference: 'Q9HTDF7-02')
      loan.should be_created_from_transfer
    end

    it "returns false when loan with next incremented loan reference does not exist" do
      loan = FactoryGirl.build(:loan, reference: 'Q9HTDF7-01')
      loan.should_not be_created_from_transfer
    end

    it "returns false when loan has no reference" do
      Loan.new.should_not be_created_from_transfer
    end
  end

  describe '#efg_loan?' do
    it "returns true when loan source is SFLG and loan type is EFG" do
      loan.loan_source = Loan::SFLG_SOURCE
      loan.loan_scheme = Loan::EFG_SCHEME

      loan.should be_efg_loan
    end

    it "returns false when loan source is not SFLG" do
      loan.loan_source = Loan::LEGACY_SFLG_SOURCE
      loan.loan_scheme = Loan::EFG_SCHEME

      loan.should_not be_efg_loan
    end

    it "returns false when loan source is SFLG but loan type is not EFG" do
      loan.loan_source = Loan::SFLG_SOURCE
      loan.loan_scheme = Loan::SFLG_SCHEME

      loan.should_not be_efg_loan
    end
  end

  describe '#legacy_loan?' do
    it "returns true when loan source is legacy SFLG" do
      loan.loan_source = Loan::LEGACY_SFLG_SOURCE

      loan.should be_legacy_loan
    end

    it "returns false when loan source is not legacy SFLG" do
      loan.loan_source = Loan::SFLG_SOURCE

      loan.should_not be_legacy_loan
    end
  end

  describe "#transferred_from" do
    let(:original_loan) { FactoryGirl.create(:loan, :repaid_from_transfer) }

    let(:transferred_loan) { FactoryGirl.create(:loan, transferred_from_id: original_loan.id) }

    it "returns the original loan from which this loan was transferred" do
      transferred_loan.transferred_from.should == original_loan
    end

    it "returns nil when loan is not a transfer" do
      Loan.new.transferred_from.should be_nil
    end
  end

  describe "#loan_security_types" do
    let(:security_type1) { LoanSecurityType.find(1) }

    let(:security_type2) { LoanSecurityType.find(5) }

    let!(:loan) {
      loan = FactoryGirl.create(:loan)
      loan.loan_security_types = [ security_type1.id, security_type2.id ]
      loan
    }

    it "should return all loan security types for a loan" do
      loan.loan_security_types.should == [ security_type1, security_type2 ]
    end
  end

  describe "#guarantee_rate" do
    before do
      loan.guarantee_rate = 75
      loan.loan_allocation.guarantee_rate = 85
    end

    it "returns the loan's guarantee rate when present" do
      loan.guarantee_rate.should == 75
    end

    it "returns the loan's loan allocation guarantee rate when present" do
      loan.guarantee_rate = nil
      loan.guarantee_rate.should == 85
    end
  end

  describe "#premium_rate" do
    before do
      loan.premium_rate = 1.5
      loan.loan_allocation.premium_rate = 2
    end

    it "returns the loan's premium rate when present" do
      loan.premium_rate.should == 1.5
    end

    it "returns the loan's loan allocation premium rate when present" do
      loan.premium_rate = nil
      loan.premium_rate.should == 2
    end
  end

  describe "#state_history" do
    it "should return array of unique states a loan has or previously had" do
      loan.state = Loan::Demanded
      loan.save!

      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Eligible)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Completed)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Offered)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Guaranteed)
      FactoryGirl.create(:loan_state_change, loan: loan, state: Loan::Guaranteed)

      loan.state_history.should == [
        Loan::Eligible,
        Loan::Completed,
        Loan::Offered,
        Loan::Guaranteed,
        Loan::Demanded
      ]
    end
  end

end
