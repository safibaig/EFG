require 'spec_helper'

describe LoanRemoveGuarantee do

  describe 'validations' do
    let(:loan_remove_guarantee) { FactoryGirl.build(:loan_remove_guarantee) }

    it 'should have a valid factory' do
      loan_remove_guarantee.should be_valid
    end

    it 'should be invalid without remove guarantee on' do
      loan_remove_guarantee.remove_guarantee_on = nil
      loan_remove_guarantee.should_not be_valid
    end

    it 'should be invalid without remove guarantee outstanding amount' do
      loan_remove_guarantee.remove_guarantee_outstanding_amount = nil
      loan_remove_guarantee.should_not be_valid
    end

    it 'should be invalid without a cancelled date' do
      loan_remove_guarantee.remove_guarantee_reason = nil
      loan_remove_guarantee.should_not be_valid
    end
  end

end
