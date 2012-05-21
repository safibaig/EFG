require 'spec_helper'

describe LoanEligibilityCheck do
  describe '#amount' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'is formatted with pence' do
      loan_eligibility_check.loan.amount = 12345
      loan_eligibility_check.amount.to_s.should == '123.45'
    end

    it 'is nil for a zero value' do
      loan_eligibility_check.amount.should be_nil
    end
  end

  describe '#amount=' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'is stored as an integer' do
      loan_eligibility_check.amount = '123.45'
      loan_eligibility_check.loan.amount.should == 12345
    end

    it 'is zero for a blank value' do
      loan_eligibility_check.amount = ''
      loan_eligibility_check.loan.amount.should == 0
    end
  end

  describe '#repayment_duration' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'conforms to the MonthDuration interface' do
      loan_eligibility_check.loan.repayment_duration = 18
      loan_eligibility_check.repayment_duration.years.should == 1
      loan_eligibility_check.repayment_duration.months.should == 6
    end
  end

  describe '#repayment_duration=' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'converts year/months hash to months' do
      loan_eligibility_check.repayment_duration = { years: 1, months: 6 }
      loan_eligibility_check.loan.repayment_duration.should == 18
    end

    it 'handles blank inputs' do
      loan_eligibility_check.repayment_duration = { years: '', months: '' }
      loan_eligibility_check.loan.repayment_duration.should == 0
    end
  end

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

  describe '#turnover' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'is formatted with pence' do
      loan_eligibility_check.loan.turnover = 12345
      loan_eligibility_check.turnover.to_s.should == '123.45'
    end

    it 'is nil for a zero value' do
      loan_eligibility_check.turnover.should be_nil
    end
  end

  describe '#turnover=' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'is stored as an integer' do
      loan_eligibility_check.turnover = '123.45'
      loan_eligibility_check.loan.turnover.should == 12345
    end

    it 'is zero for a blank value' do
      loan_eligibility_check.turnover = ''
      loan_eligibility_check.loan.turnover.should == 0
    end
  end
end
