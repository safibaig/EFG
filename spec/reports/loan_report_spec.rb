require 'spec_helper'

describe LoanReport do

  describe "validation" do
    let(:loan_report) { FactoryGirl.build(:loan_report) }

    it 'should have a valid factory' do
      loan_report.should be_valid
    end

    it 'should be invalid without a loan state' do
      loan_report.loan_state = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan state' do
      loan_report.loan_state = "wrong"
      loan_report.should_not be_valid

      loan_report.loan_state = "All"
      loan_report.should be_valid
    end

    it 'should be invalid without created by user ID' do
      loan_report.created_by_user_id = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without a loan type' do
      loan_report.loan_type = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan type' do
      loan_report.loan_type = "Z"
      loan_report.should_not be_valid

      loan_report.loan_type = Loan::LEGACY_SFLG_SOURCE
      loan_report.should be_valid
    end

    it 'should be invalid without a loan scheme' do
      loan_report.loan_scheme = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan scheme' do
      loan_report.loan_scheme = "Z"
      loan_report.should_not be_valid

      loan_report.loan_scheme = Loan::EFG_SCHEME
      loan_report.should be_valid
    end

    it 'should be invalid without lender ID' do
      loan_report.lender_id = nil
      loan_report.should_not be_valid
    end
  end

end
