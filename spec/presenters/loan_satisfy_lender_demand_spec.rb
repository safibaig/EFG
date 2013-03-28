require 'spec_helper'

describe LoanSatisfyLenderDemand do
  describe 'validations' do
    let(:presenter) { FactoryGirl.build(:loan_satisfy_lender_demand) }

    it 'has a valid factory' do
      presenter.should be_valid
    end

    it 'requires a date_of_change' do
      presenter.date_of_change = nil
      presenter.should_not be_valid
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :lender_demand) }
    let(:presenter) { FactoryGirl.build(:loan_satisfy_lender_demand, loan: loan, modified_by: user) }

    it 'creates a LoanChange, a PremiumSchedule, and updates the loan' do
      presenter.save.should == true

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::LenderDemandSatisfied
      loan_change.created_by.should == user

      loan.reload
      loan.state.should == Loan::Guaranteed
      loan.modified_by.should == user
    end
  end
end
