require 'spec_helper'

describe TransferredLoanEntry do

  describe "#initialize" do
    let(:loan) { FactoryGirl.build(:loan, :incomplete) }

    it 'raises exception when loan is not a transferred loan' do
      expect {
        TransferredLoanEntry.new(loan)
      }.to raise_error(ArgumentError)
    end
  end

  describe "validations" do
    let(:transferred_loan_entry) { FactoryGirl.build(:transferred_loan_entry) }

    it "should have a valid factory" do
      transferred_loan_entry.should be_valid
    end

    it "should be invalid if the declaration hasn't been signed" do
      transferred_loan_entry.declaration_signed = false
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a amount" do
      transferred_loan_entry.amount = ''
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment duration" do
      transferred_loan_entry.repayment_duration = ''
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment frequency" do
      transferred_loan_entry.repayment_frequency_id = nil
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a state aid calculation" do
      transferred_loan_entry.loan.state_aid_calculations.delete_all
      transferred_loan_entry.should_not be_valid
      transferred_loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    it_behaves_like 'loan presenter that validates loan repayment frequency' do
      let(:loan_presenter) { transferred_loan_entry }
    end
  end
end
