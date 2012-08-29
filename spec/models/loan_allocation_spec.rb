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

    it 'requires a guarantee rate' do
      loan_allocation.guarantee_rate = nil
      loan_allocation.should_not be_valid
    end

    it 'requires a premium rate' do
      loan_allocation.premium_rate = nil
      loan_allocation.should_not be_valid
    end

    it 'requires a valid allocation_type_id' do
      loan_allocation.allocation_type_id = ''
      loan_allocation.should_not be_valid
      loan_allocation.allocation_type_id = '99'
      loan_allocation.should_not be_valid
      loan_allocation.allocation_type_id = '1'
      loan_allocation.should be_valid
    end

    it 'requires a description' do
      loan_allocation.description = ''
      loan_allocation.should_not be_valid
    end
  end

  it "has many loans using allocation" do
    loan_allocation = FactoryGirl.create(:loan_allocation)

    expected_loans = LoanAllocation::USAGE_LOAN_STATES.collect do |state|
      FactoryGirl.create(:loan, state: state, loan_allocation: loan_allocation)
    end

    eligible_loan = FactoryGirl.create(:loan, :eligible, loan_allocation: loan_allocation)

    loan_allocation.loans_using_allocation.should == expected_loans
  end

end
