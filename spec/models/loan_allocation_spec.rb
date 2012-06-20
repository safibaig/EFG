require 'spec_helper'

describe LoanAllocation do

  describe 'validations' do
    let(:loan_allocation) { FactoryGirl.build(:loan_allocation) }

    it 'has a valid Factory' do
      loan_allocation.should be_valid
    end

    it 'requires a lender' do
      loan_allocation.lender = nil
      loan_allocation.should_not be_valid
    end

    it 'requires an allocation' do
      loan_allocation.allocation = nil
      loan_allocation.should_not be_valid
    end

    it 'requires a starts_on date' do
      loan_allocation.starts_on = nil
      loan_allocation.should_not be_valid
    end

    it 'requires a ends_on date' do
      loan_allocation.ends_on = nil
      loan_allocation.should_not be_valid
    end

  end

  it "has many completed loans" do
    loan_allocation = FactoryGirl.create(:loan_allocation)

    guaranteed_loan = FactoryGirl.create(:loan, :guaranteed, loan_allocation: loan_allocation)
    eligible_loan = FactoryGirl.create(:loan, :eligible, loan_allocation: loan_allocation)

    loan_allocation.completed_loans.should == [guaranteed_loan]
  end

end
