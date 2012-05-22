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
      attributes = FactoryGirl.attributes_for(:loan_eligibility_check)
      loan_eligibility_check = LoanEligibilityCheck.new(lender, attributes)

      expect {
        loan_eligibility_check.save
      }.to change(Loan, :count).by(1)

      Loan.last.lender.should == lender
    end
  end

  describe '#trading_date=' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new(mock_model(Lender)) }

    it 'correctly parses dd/mm/yyyy' do
      loan_eligibility_check.trading_date = '11/1/2011'
      loan_eligibility_check.loan.trading_date.should == Date.new(2011, 1, 11)
    end

    it 'correctly parses dd/mm/yy' do
      loan_eligibility_check.trading_date = '11/1/11'
      loan_eligibility_check.loan.trading_date.should == Date.new(2011, 1, 11)
    end

    it 'does not blow up for a blank value' do
      loan_eligibility_check.trading_date = ''
      loan_eligibility_check.loan.trading_date.should be_nil
    end
  end
end
