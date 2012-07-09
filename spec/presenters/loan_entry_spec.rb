require 'spec_helper'

describe LoanEntry do
  describe "validations" do
    let(:loan_entry) { FactoryGirl.build(:loan_entry) }

    it "should have a valid factory" do
      loan_entry.should be_valid
    end

    it "should be invalid if the declaration hasn't been signed" do
      loan_entry.declaration_signed = false
      loan_entry.should_not be_valid
    end

    it "should be invalid if interest rate type isn't selected" do
      loan_entry.interest_rate_type_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business name" do
      loan_entry.business_name = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business type" do
      loan_entry.legal_form_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a postcode" do
      loan_entry.postcode = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment frequency" do
      loan_entry.repayment_frequency_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a maturity date" do
      loan_entry.maturity_date = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without an interest rate" do
      loan_entry.interest_rate = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without fees" do
      loan_entry.fees = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a state aid calculation" do
      loan_entry.loan.state_aid_calculation = nil
      loan_entry.should_not be_valid
      loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    # Although a business may benefit from EFG on more than one occasion, and may have more than one EFG-backed facility at any one time, the total outstanding balances and/or active available limits of the Applicant's current EFG facilities may not exceed £1 million at any one time.
    # To be eligible for EFG the Applicant's De Minimis State Aid status must be checked to ensure that it does not exceed the €200,000 rolling three year limit (or the corresponding lower limit applicable in certain business sectors). On this occasion that check has not been performed.
  end
end
