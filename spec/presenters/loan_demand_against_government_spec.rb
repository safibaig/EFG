require 'spec_helper'

describe LoanDemandAgainstGovernment do
  describe 'validations' do
    let(:loan_demand_against_government) { FactoryGirl.build(:loan_demand_against_government) }

    it 'should have a valid factory' do
      loan_demand_against_government.should be_valid
    end

    it 'should be invalid without demanded outstanding' do
      loan_demand_against_government.dti_demand_outstanding = nil
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without demanded reason' do
      loan_demand_against_government.dti_reason = ''
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without a demanded date' do
      loan_demand_against_government.dti_demanded_on = ''
      loan_demand_against_government.should_not be_valid
    end
  end
end
