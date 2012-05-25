require 'spec_helper'

describe LoanEligibilityCheck do
  describe 'validations' do
    let(:loan_eligibility_check) { FactoryGirl.build(:loan_eligibility_check) }

    it 'has a valid factory' do
      loan_eligibility_check.should be_valid
    end
  end

  describe '#save' do
    let(:lender) { FactoryGirl.create(:lender) }

    it 'assigns the specified lender to the created loan' do
      loan_eligibility_check = LoanEligibilityCheck.new(lender.loans.new)

      attributes = FactoryGirl.attributes_for(:loan_eligibility_check)
      loan_eligibility_check.attributes = attributes

      expect {
        loan_eligibility_check.save
      }.to change(Loan, :count).by(1)

      Loan.last.lender.should == lender
    end
  end
end
