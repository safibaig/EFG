require 'spec_helper'

describe LoanReport do
  describe "#count" do
    let!(:loan1) { FactoryGirl.create(:loan, :eligible) }
    let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }
    let(:loan_report) { LoanReport.new }

    it "returns the total number of loans matching the report criteria" do
      loan_report.count.should == 2
    end

    it "returns the total number of loans with state guaranteed" do
      loan_report.states = [ Loan::Guaranteed ]
      loan_report.count.should == 1
    end
  end

  describe "#loans" do
    let!(:loan1) { FactoryGirl.create(:loan) }
    let!(:loan2) { FactoryGirl.create(:loan) }
    let(:loan_report) { LoanReport.new }

    it "returns all loans when matching the default report criteria" do
      loan_report.loans.should == [loan1, loan2]
    end

    it "returns loans with a specific state" do
      guaranteed_loan = FactoryGirl.create(:loan, :guaranteed)

      loan_report.states = [Loan::Guaranteed]
      loan_report.loans.should == [guaranteed_loan]
    end

    it "returns loans with a specific loan scheme" do
      sflg_loan = FactoryGirl.create(:loan, :sflg)

      loan_report.loan_scheme = Loan::SFLG_SCHEME
      loan_report.loans.should == [sflg_loan]
    end

    it "returns loans with a specific loan source" do
      legacy_sflg_loan = FactoryGirl.create(:loan, loan_source: Loan::LEGACY_SFLG_SOURCE)

      loan_report.loan_sources = [Loan::LEGACY_SFLG_SOURCE]
      loan_report.loans.should == [legacy_sflg_loan]
    end

    it "returns Legacy_SFLG loans with a NULL modified_by_legacy_id" do
      legacy_sflg_loan = FactoryGirl.create(:loan, loan_source: Loan::LEGACY_SFLG_SOURCE, modified_by_legacy_id: nil)

      loan_report.loan_sources = [Loan::LEGACY_SFLG_SOURCE]
      loan_report.loans.should == [legacy_sflg_loan]
    end

    it "returns loans with a facility letter date after a specified date" do
      loan1.update_attribute(:facility_letter_date, 1.day.ago)
      loan2.update_attribute(:facility_letter_date, 1.day.from_now)

      loan_report.facility_letter_start_date = Date.today
      loan_report.loans.should == [loan2]
    end

    it "returns loans with a facility letter date before a specified date" do
      loan1.update_attribute(:facility_letter_date, 1.day.ago)
      loan2.update_attribute(:facility_letter_date, 1.day.from_now)

      loan_report.facility_letter_end_date = Date.today
      loan_report.loans.should == [loan1]
    end

    it "returns loans with a created at date after a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_report.created_at_start_date = Date.today
      loan_report.loans.should == [loan2]
    end

    it "returns loans with a created at date before a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_report.created_at_end_date = Date.today
      loan_report.loans.should == [loan1]
    end

    it "returns loans last modified on the specified start date" do
      loan1.update_attribute(:last_modified_at, Time.new(2013, 02, 26, 23, 59, 59))
      loan2.update_attribute(:last_modified_at, Time.new(2013, 02, 27, 12,  0,  0))

      loan_report.last_modified_start_date = Date.new(2013, 2, 27)
      loan_report.loans.should == [loan2]
    end

    it "returns loans last modified after the specified start date" do
      loan1.update_attribute(:last_modified_at, Time.new(2013, 02, 26, 23, 59, 59))
      loan2.update_attribute(:last_modified_at, Time.new(2013, 02, 28, 12,  0,  0))

      loan_report.last_modified_start_date = Date.new(2013, 2, 27)
      loan_report.loans.should == [loan2]
    end

    it "returns loans last modified on the specified end date" do
      loan1.update_attribute(:last_modified_at, Time.new(2013, 02, 27, 12,  0,  0))
      loan2.update_attribute(:last_modified_at, Time.new(2013, 02, 28,  0,  0,  0))

      loan_report.last_modified_end_date = Date.new(2013, 2, 27)
      loan_report.loans.should == [loan1]
    end

    it "returns loans last modified before the specified end date" do
      loan1.update_attribute(:last_modified_at, Time.new(2013, 02, 26, 12,  0,  0))
      loan2.update_attribute(:last_modified_at, Time.new(2013, 02, 28,  0,  0,  0))

      loan_report.last_modified_end_date = Date.new(2013, 2, 27)
      loan_report.loans.should == [loan1]
    end

    it "returns loans belonging to a specific lender" do
      loan_report.lender_ids = [loan1.lender_id]
      loan_report.loans.should == [loan1]
    end

    context 'with loans created by specific users' do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      before do
        loan1.update_attribute(:created_by, user1)
        loan2.update_attribute(:created_by, user2)
      end

      it "returns loans created by a specific user" do
        loan_report.created_by_id = user2.id
        loan_report.loans.should == [loan2]
      end

      it "returns no loans when specified created by user does not belong to one of the specified lenders" do
        loan_report.lender_ids = [loan1.lender_id]
        loan_report.created_by_id = user2.id
        loan_report.loans.should be_empty
      end
    end

    it "should ignore blank values" do
      loan_report.facility_letter_start_date = ""
      loan_report.loans.should == [loan1, loan2]
    end

    it "should not include legacy SFLG loans with a legacy modified by id of 'migration'" do
      FactoryGirl.create(:loan, :legacy_sflg, modified_by_legacy_id: 'migration')

      loan_report.loan_sources = [Loan::LEGACY_SFLG_SOURCE, Loan::SFLG_SOURCE]
      loan_report.loans.should == [loan1, loan2]
    end
  end
end
