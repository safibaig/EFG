# encoding: utf-8
require 'spec_helper'

describe EligibilityCheck do
  describe "eligibility checks" do
    let(:loan) { FactoryGirl.build(:loan) }
    let(:eligibility_check) { EligibilityCheck.new(loan) }

    it "should have a loan that is eligible by default" do
      eligibility_check.eligible?
      eligibility_check.should be_eligible
    end

    it "should be ineligible when it's not a viable proposition" do
      loan.viable_proposition = false

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:viable_proposition].should_not be_empty
    end

    it "should be ineligible when the lender doesn't wish to lend" do
      loan.would_you_lend = false

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:would_you_lend].should_not be_empty
    end

    it "should be ineligible if collateral isn't exhausted" do
      loan.collateral_exhausted = false

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:collateral_exhausted].should_not be_empty
    end

    it "should be ineligible if the Loan Facility lending limit is exhausted" do
      pending
    end

    it "should be ineligible if the SIC code is not allowed to receive suport" do
      pending
    end

    it "should be ineligible if a private residence charge is required" do
      loan.private_residence_charge_required = true

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:private_residence_charge_required].should_not be_empty
    end

    it "should ineligible if a personal guarantee is required" do
      pending "Not quite sure on this requirement yet."
      loan.personal_guarantee_required = true

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:personal_guarantee_required].should_not be_empty
    end

    it "should be ineligible if the amount is less than £1000" do
      loan.amount = Money.new(99999) # £999.99

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:amount].should_not be_empty
    end

    it "should be ineligible if the amount is greater than £1,000,000" do
      loan.amount = Money.new(100000001) # £1,000,000.01

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:amount].should_not be_empty
    end

    it "should be ineligible if the repayment duration is less than 3 months" do
      loan.repayment_duration = {months: 2}

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:repayment_duration].should_not be_empty
    end

    it "should be ineligible if the repayment duration is longer than 10 years" do
      loan.repayment_duration = {years: 10, months: 1}

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:repayment_duration].should_not be_empty
    end

    it "should be ineligible if the loan is a Type E facility and repayment duration is longer than 2 years" do
      pending

      loan.loan_category_id = 5 # Type E facility
      loan.repayment_duration = {years: 2, months: 1}

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:repayment_duration].should_not be_empty
    end

    it "should be ineligible if the loan is a Type F facility and repayment duration is longer than 3 years" do
      pending

      loan.loan_category_id = 6 # Type F facility
      loan.repayment_duration = {years: 3, months: 1}

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:repayment_duration].should_not be_empty
    end

    it "should be ineligible with a trading date that...." do
      pending
    end

    it "should be ineligible if previous borrowing + this amount is not greater than £1,000,000" do
      loan.previous_borrowing = false

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:previous_borrowing].should_not be_empty
    end

    it "should be ineligible when SIC code is ineligible" do
      loan.sic_eligible = false

      eligibility_check.should_not be_eligible
      eligibility_check.errors[:sic_code].should_not be_empty
    end
  end
end
