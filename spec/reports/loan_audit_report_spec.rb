require 'spec_helper'

describe LoanAuditReport do

  let!(:loan1) { FactoryGirl.create(:loan, :eligible, reference: 'ABC123') }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed, reference: 'DEF456') }

  let!(:loan_state_change1) { FactoryGirl.create(:accepted_loan_state_change, loan: loan1) }

  let!(:loan_state_change2) { FactoryGirl.create(:guaranteed_loan_state_change, loan: loan2) }

  let(:loan_audit_report) { LoanAuditReport.new }

  describe "#count" do

    it "should return the total number of loans matching the report criteria" do
      loan_audit_report.count.should == 2
    end

    it "should return the total number of loans with state guaranteed" do
      loan_audit_report.state = Loan::Guaranteed
      loan_audit_report.count.should == 1
    end

  end

  describe "#loans" do

    it "should return all loans when matching the default report criteria" do
      loan_audit_report.loans.should == [loan1, loan2]
    end

    it "should return loans with a specific state" do
      loan_audit_report = LoanAuditReport.new(state: Loan::Guaranteed)
      loan_audit_report.loans.should == [ loan2 ]
    end

    it "should return loans for a specific lender" do
      loan_audit_report = LoanAuditReport.new(lender_id: loan1.lender_id)
      loan_audit_report.loans.should == [ loan1 ]
    end

    it "should return loans for a specific event" do
      loan_audit_report = LoanAuditReport.new(event_id: loan_state_change1.event_id)
      loan_audit_report.loans.should == [ loan1 ]
    end

    context 'with initial draw' do
      let!(:loan1) { FactoryGirl.create(:loan, :guaranteed) }

      before(:each) do
        loan1.initial_draw_change.update_attribute(:date_of_change, 1.day.ago)
        loan2.initial_draw_change.update_attribute(:date_of_change, 1.day.from_now)
      end

      it "should return loans with an initial draw date after a specified date" do
        loan_audit_report = LoanAuditReport.new(facility_letter_start_date: Date.today.strftime('%d/%m/%Y'))
        loan_audit_report.loans.should == [ loan2 ]
      end

      it "should return loans with an initial draw date before a specified date" do
        loan_audit_report = LoanAuditReport.new(facility_letter_end_date: Date.today.strftime('%d/%m/%Y'))
        loan_audit_report.loans.should == [ loan1 ]
      end
    end

    it "should return loans with a created at date after a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(created_at_start_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan2 ]
    end

    it "should return loans with a created at date before a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(created_at_end_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan1 ]
    end

    it "should return loans with a modified at date after a specified date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(last_modified_start_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan2 ]
    end

    it "should return loans with a modified at date before a specified date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(last_modified_end_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan1 ]
    end

    it "should return loans with an audit record modified at date after a specified date" do
      loan_state_change1.update_attribute(:modified_at, 1.day.ago)
      loan_state_change2.update_attribute(:modified_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(audit_records_start_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan2 ]
    end

    it "should return loans with an audit record modified at date before a specified date" do
      loan_state_change1.update_attribute(:modified_at, 1.day.ago)
      loan_state_change2.update_attribute(:modified_at, 1.day.from_now)

      loan_audit_report = LoanAuditReport.new(audit_records_end_date: Date.today.strftime('%d/%m/%Y'))

      loan_audit_report.loans.should == [ loan1 ]
    end

  end

end
