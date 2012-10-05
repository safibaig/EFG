require 'spec_helper'

describe LoanRemoveGuarantee do

  describe 'validations' do
    let(:loan_remove_guarantee) { FactoryGirl.build(:loan_remove_guarantee) }

    let(:loan) { loan_remove_guarantee.loan }

    before(:each) do
      loan.save!
      FactoryGirl.create(:initial_draw_change, amount_drawn: loan.amount, loan: loan)
    end

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

    it "should be invalid when remove guarantee outstanding amount is greater than total amount drawn" do
      loan_remove_guarantee.remove_guarantee_outstanding_amount = loan.amount + Money.new(1_00)
      loan_remove_guarantee.should_not be_valid

      loan_remove_guarantee.remove_guarantee_outstanding_amount = loan.amount
      loan_remove_guarantee.should be_valid
    end

    it "should be invalid when remove guarantee date is before initial draw date" do
      loan_remove_guarantee.remove_guarantee_on = loan.initial_draw_change.date_of_change - 1.day
      loan_remove_guarantee.should_not be_valid

      loan_remove_guarantee.remove_guarantee_on = loan.initial_draw_change.date_of_change
      loan_remove_guarantee.should be_valid
    end
  end

end
