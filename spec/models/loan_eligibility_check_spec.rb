require 'spec_helper'

describe LoanEligibilityCheck do
  describe '#repayment_duration' do
    let(:loan_eligibility_check) { LoanEligibilityCheck.new }

    it 'is a hash with years/months' do
      loan_eligibility_check.loan.repayment_duration = 18
      loan_eligibility_check.repayment_duration.should == { years: 1, months: 6 }
    end

    it 'handles blank value' do
      loan_eligibility_check.repayment_duration.should == { years: 0, months: 0 }
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
end
