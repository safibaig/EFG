require 'spec_helper'

describe LoanDemandAgainstGovernment do
  describe 'validations' do
    let(:loan_demand_against_government) { FactoryGirl.build(:loan_demand_against_government) }

    it 'should have a valid factory' do
      loan_demand_against_government.should be_valid
    end

    it 'should be invalid without demanded amount' do
      loan_demand_against_government.amount_demanded = nil
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without a demanded date' do
      loan_demand_against_government.dti_demanded_on = ''
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without a DED code' do
      loan_demand_against_government.dti_ded_code = ''
      loan_demand_against_government.should_not be_valid
    end
  end
end
