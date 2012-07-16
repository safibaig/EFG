require 'spec_helper'

describe TransferredLoanEntry do

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

    it "should be invalid without a maturity date" do
      transferred_loan_entry.maturity_date = nil
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a state aid calculation" do
      transferred_loan_entry.loan.state_aid_calculation = nil
      transferred_loan_entry.should_not be_valid
      transferred_loan_entry.errors[:state_aid].should == ['must be calculated']
    end
  end
end
