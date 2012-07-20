require 'spec_helper'

describe LoanDemandToBorrower do
  describe 'validations' do
    let(:loan_demand_to_borrower) { FactoryGirl.build(:loan_demand_to_borrower) }

    it 'should have a valid factory' do
      loan_demand_to_borrower.should be_valid
    end

    it 'should be invalid without a borrower demanded date' do
      loan_demand_to_borrower.borrower_demanded_on = ''
      loan_demand_to_borrower.should_not be_valid
    end

    it 'should be invalid without borrower demanded amount' do
      loan_demand_to_borrower.borrower_demand_outstanding = ''
      loan_demand_to_borrower.should_not be_valid
    end
  end
end
