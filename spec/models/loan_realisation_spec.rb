require 'spec_helper'

describe LoanRealisation do

  describe 'validations' do

    let(:loan_realisation) { FactoryGirl.build(:loan_realisation) }

    it 'should have a valid factory' do
      loan_realisation.should be_valid
    end

    it 'must have a realised loan' do
      loan_realisation.realised_loan = nil
      loan_realisation.should_not be_valid
    end

    it 'must have a realisation statement' do
      loan_realisation.realisation_statement = nil
      loan_realisation.should_not be_valid
    end

  end

end
