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

  end

end
