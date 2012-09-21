require 'spec_helper'

describe LoanStateChange do
  let(:loan_state_change) { FactoryGirl.build(:loan_state_change) }

  describe 'validations' do
    it 'has a valid Factory' do
      loan_state_change.should be_valid
    end

    it 'strictly requires a loan' do
      expect {
        loan_state_change.loan = nil
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a state' do
      expect {
        loan_state_change.state = nil
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires an event_id' do
      expect {
        loan_state_change.event_id = nil
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a known event_id' do
      expect {
        loan_state_change.event_id = 99
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a modified_on' do
      expect {
        loan_state_change.modified_on = nil
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a modified_by_id' do
      expect {
        loan_state_change.modified_by_id = nil
        loan_state_change.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
