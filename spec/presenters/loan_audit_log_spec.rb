require 'spec_helper'

describe LoanAuditLog do

  let(:loan_state_change) { FactoryGirl.build(:guaranteed_loan_state_change, modified_at: Time.zone.local(2012, 10, 5, 11, 00)) }

  let(:loan_audit_log) { LoanAuditLog.new(loan_state_change) }

  describe '.generate' do
    let(:audit_log_entries) { LoanAuditLog.generate([ loan_state_change ]) }

    it "should return array of LoanAuditLog instances" do
      audit_log_entries.should be_instance_of(Array)
      audit_log_entries.size.should == 1
      audit_log_entries.first.should be_instance_of(LoanAuditLog)
    end
  end

  describe '#event_name' do
    it 'should return "Check Eligibility" when event name is "Accept"' do
      loan_state_change.event_id = 0
      loan_audit_log.event_name.should == 'Check Eligibility'
    end

    it 'should return "Check Eligibility" when event name is "Reject"' do
      loan_state_change.event_id = 1
      loan_audit_log.event_name.should == 'Check Eligibility'
    end

    it 'should return event name' do
      loan_audit_log.event_name.should == LoanEvent::Guaranteed.name
    end
  end

  describe '#from_state' do
    it 'should return "Created" when loan has no previous loan state change' do
      loan_audit_log.from_state.should == 'Created'
    end

    it 'should return state of previous loan state change' do
      previous_loan_state_change = FactoryGirl.build(:offered_loan_state_change)
      loan_audit_log = LoanAuditLog.new(loan_state_change)
    end
  end

  describe '#to_state' do
    it 'should return humanized loan state change state' do
      loan_audit_log.to_state.should == Loan::Guaranteed.humanize
    end
  end


  describe '#modified_at' do
    it 'should return formatted date time' do
      loan_audit_log.modified_at.should == Time.zone.local(2012, 10, 5, 11, 00).strftime("%d/%m/%Y %I:%M")
    end
  end

  describe '#modified_by' do
    it 'should return full name of user' do
      loan_audit_log.modified_by.should == loan_state_change.modified_by.name
    end
  end

end
