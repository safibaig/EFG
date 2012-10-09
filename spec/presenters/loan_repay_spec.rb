require 'spec_helper'

describe LoanRepay do
  describe 'validations' do
    let(:loan_repay) { FactoryGirl.build(:loan_repay) }

    it 'should have a valid factory' do
      loan_repay.should be_valid
    end

    it 'should be invalid without a repaid date' do
      loan_repay.repaid_on = ''
      loan_repay.should_not be_valid
    end

    it 'should be invalid if repaid date is before initial draw date' do
      initial_draw_date = loan_repay.loan.initial_draw_change.date_of_change

      loan_repay.repaid_on = initial_draw_date - 1.day
      loan_repay.should_not be_valid

      loan_repay.repaid_on = initial_draw_date
      loan_repay.should be_valid
    end
  end
end
