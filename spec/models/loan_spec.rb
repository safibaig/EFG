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
    let!(:loan1) { FactoryGirl.create(:loan, :updated_at => 3.days.ago) }
    let!(:loan2) { FactoryGirl.create(:loan, :updated_at => 1.day.ago) }

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
    let!(:loan1) { FactoryGirl.create(:loan, reference: "ABC123") }
    let!(:loan2) { FactoryGirl.create(:loan, reference: "ABC12345") }

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

  describe "#state_aid_value" do
    it "should return a EUR money object" do
      loan = FactoryGirl.build(:loan, state_aid_value: '100.00')
      loan.state_aid_value.should == Money.new(100_00, 'EUR')
    end

    it "return nil if not set" do
      loan = FactoryGirl.build(:loan, state_aid_value: '')
      loan.state_aid_value.should be_nil
    end
  end
end
