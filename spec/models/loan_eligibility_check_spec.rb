require 'spec_helper'

describe LoanEligibilityCheck do
  describe '#trading_date=' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

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
