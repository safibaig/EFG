require 'spec_helper'

describe LoanStateChange do

  let(:loan_state_change) { FactoryGirl.build(:loan_state_change) }

  describe 'validations' do
    it 'has a valid Factory' do
      loan_state_change.should be_valid
    end

    it 'requires a loan_id' do
      loan_state_change.loan_id = nil
      loan_state_change.should_not be_valid
    end

    it 'requires a state' do
      loan_state_change.state = nil
      loan_state_change.should_not be_valid
    end

    it 'requires an event_id' do
      loan_state_change.event_id = nil
      loan_state_change.should_not be_valid
    end

    it 'requires a modified_on date' do
      loan_state_change.modified_on = nil
      loan_state_change.should_not be_valid
    end

    it 'requires a modified_by_id' do
      loan_state_change.modified_by_id = nil
      loan_state_change.should_not be_valid
    end
  end

end
