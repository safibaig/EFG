require 'spec_helper'

describe Loan do
  describe 'validations' do
    let(:loan) { FactoryGirl.build(:loan) }

    it 'has a valid Factory' do
      loan.should be_valid
    end

    it 'requires a lender' do
      pending "This relies on rails 3.2 features"
      # expect {
      #   loan.lender = nil
      #   loan.valid?
      # }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a state' do
      pending "This relies on rails 3.2 features"
      # expect {
      #   loan.state = nil
      #   loan.valid?
      # }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a known state' do
      pending "This relies on rails 3.2 features"
      # expect {
      #   loan.state = 'not-a-known-state-yo'
      #   loan.valid?
      # }.to raise_error(ActiveModel::StrictValidationFailed)
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

  describe "#created_by" do
    pending "currently returns a canned response"
  end

  describe "#updated_by" do
    pending "currently returns a canned response"
  end

  describe "#premium_schedule" do
    it "should return a PremiumSchedule for the loan" do
      loan = FactoryGirl.build(:loan)
      loan.build_state_aid_calculation

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

  describe "#transferred?" do
    it "returns true when a loan with the next incremented loan reference exists" do
      FactoryGirl.create(:loan, reference: 'Q9HTDF7-02')

      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should be_transferred
    end

    it "returns false when loan with next incremented loan reference does not exist" do
      FactoryGirl.build(:loan, reference: 'Q9HTDF7-01').should_not be_transferred
    end
  end
end
