require 'spec_helper'

describe RealisationStatement do
  let(:realisation_statement) { FactoryGirl.build(:realisation_statement) }

  describe "validations" do

    it 'should have a valid factory' do
      realisation_statement.should be_valid
    end

    it 'must have a lender' do
      realisation_statement.lender = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a created by user' do
      realisation_statement.created_by = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a reference' do
      realisation_statement.reference = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a period recovery quarter' do
      realisation_statement.period_covered_quarter = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period recovery quarter' do
      realisation_statement.period_covered_quarter = 'April'
      realisation_statement.should_not be_valid
    end

    it 'must have a period covered year' do
      realisation_statement.period_covered_year = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period covered year' do
      realisation_statement.period_covered_year = '201'
      realisation_statement.should_not be_valid
    end

    it 'must have a received on date' do
      realisation_statement.received_on = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid received on date' do
      realisation_statement.received_on = '2012-05-01'
      realisation_statement.should_not be_valid
    end

  end
end
