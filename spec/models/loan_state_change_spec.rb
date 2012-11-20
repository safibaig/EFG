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

    it 'strictly requires modified_at' do
      expect {
        loan_state_change.modified_at = nil
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

  describe ".log" do
    let!(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it "should create loan state change for the specified loan and event" do
      time = Time.now
      Timecop.freeze(time) do
        LoanStateChange.log(loan, 7, loan.modified_by)
      end

      loan_state_change = LoanStateChange.last
      loan_state_change.loan.should == loan
      loan_state_change.state.should == loan.state
      loan_state_change.event_id.should == 7
      loan_state_change.modified_by.should == loan.modified_by
      loan_state_change.modified_at.to_i.should == time.to_i
    end
  end
end
