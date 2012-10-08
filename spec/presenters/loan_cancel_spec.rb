require 'spec_helper'

describe LoanCancel do
  describe 'validations' do
    let(:loan_cancel) { FactoryGirl.build(:loan_cancel) }

    it 'should have a valid factory' do
      loan_cancel.should be_valid
    end

    it 'should be invalid without cancelled reason' do
      loan_cancel.cancelled_reason_id = ''
      loan_cancel.should_not be_valid
    end

    it 'should be invalid without cancelled comments' do
      loan_cancel.cancelled_comment = ''
      loan_cancel.should_not be_valid
    end

    it 'should be invalid without a cancelled date' do
      loan_cancel.cancelled_on = ''
      loan_cancel.should_not be_valid
    end

    it 'should be invalid when cancelled_on is before loan creation date' do
      loan_cancel.loan.save!

      loan_cancel.cancelled_on = loan_cancel.loan.created_at - 1.day
      loan_cancel.should_not be_valid
      loan_cancel.cancelled_on = loan_cancel.loan.created_at
      loan_cancel.should be_valid
    end
  end
end
