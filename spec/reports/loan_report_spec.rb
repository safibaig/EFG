require 'spec_helper'
require 'csv'

describe LoanReport do

  describe "#initialize" do
    it "should not allow unsupported attributes" do
      expect {
        LoanReport.new(report_attributes(company_registration: '123456C'))
      }.to raise_error(NoMethodError)
    end
  end

  describe "validation" do
    let(:loan_report) { LoanReport.new(report_attributes) }

    it 'should have a valid factory' do
      loan_report.should be_valid
    end

    it 'should be invalid without an allowed loan state' do
      loan_report.states = [ "wrong" ]
      loan_report.should_not be_valid

      loan_report.states = [ Loan::Guaranteed ]
      loan_report.should be_valid
    end

    it 'should be invalid without numeric created by user ID' do
      loan_report.created_by_id = 'a'
      loan_report.should_not be_valid
    end

    it 'should be valid with blank created by user ID' do
      loan_report.created_by_id = ''
      loan_report.should be_valid
    end

    it 'should be invalid without a loan source' do
      loan_report.loan_sources = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan source' do
      loan_report.loan_sources = ["Z"]
      loan_report.should_not be_valid

      loan_report.loan_sources = [ Loan::LEGACY_SFLG_SOURCE ]
      loan_report.should be_valid
    end

    it 'should be valid when loan scheme is nil' do
      loan_report.loan_scheme = nil
      loan_report.should be_valid
    end

    it 'should be valid with a blank loan scheme' do
      loan_report.loan_scheme = ""
      loan_report.should be_valid
    end

    it 'should be invalid without an allowed loan scheme' do
      loan_report.loan_scheme = "Z"
      loan_report.should_not be_valid

      loan_report.loan_scheme = Loan::EFG_SCHEME
      loan_report.should be_valid
    end

    it 'should be invalid without lender IDs' do
      loan_report.lender_ids = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without a numeric created by ID' do
      loan_report.created_by_id = 'a'
      loan_report.should_not be_valid
    end

    it "should raise exception when a specified lender is not allowed" do
      loan1 = FactoryGirl.create(:loan, :eligible)
      loan2 = FactoryGirl.create(:loan, :guaranteed)

      loan_report.allowed_lender_ids = [ loan2.lender_id ]
      loan_report.lender_ids         = [ loan1.lender_id, loan2.lender_id ]

      expect {
        loan_report.valid?
      }.to raise_error(LoanReport::LenderNotAllowed)
    end
  end

  describe "#count" do

    let!(:loan1) { FactoryGirl.create(:loan, :eligible) }

    let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }

    let(:loan_report) { LoanReport.new(report_attributes) }

    it "should return the total number of loans matching the report criteria" do
      loan_report.count.should == 2
    end

    it "should return the total number of loans with state guaranteed" do
      loan_report.states = [ Loan::Guaranteed ]
      loan_report.count.should == 1
    end

  end

  describe "#loans" do

    let!(:loan1) { FactoryGirl.create(:loan) }

    let!(:loan2) { FactoryGirl.create(:loan) }

    let(:loan_report) { LoanReport.new(report_attributes) }

    it "should return all loans when matching the default report criteria" do
      loan_report.loans.should == [loan1, loan2]
    end

    it "should return loans with a specific state" do
      guaranteed_loan = FactoryGirl.create(:loan, :guaranteed)

      loan_report = LoanReport.new(report_attributes(states: [ Loan::Guaranteed ]))
      loan_report.loans.should == [ guaranteed_loan ]
    end

    it "should return loans with a specific loan scheme" do
      sflg_loan = FactoryGirl.create(:loan, :sflg)

      loan_report = LoanReport.new(report_attributes(loan_scheme: Loan::SFLG_SCHEME))
      loan_report.loans.should == [ sflg_loan ]
    end

    it "should return loans with a specific loan source" do
      legacy_sflg_loan = FactoryGirl.create(:loan, loan_source: Loan::LEGACY_SFLG_SOURCE)

      loan_report = LoanReport.new(report_attributes(loan_sources: [ Loan::LEGACY_SFLG_SOURCE ]))
      loan_report.loans.should == [ legacy_sflg_loan ]
    end

    it "should return loans with a facility letter date after a specified date" do
      loan1.update_attribute(:facility_letter_date, 1.day.ago)
      loan2.update_attribute(:facility_letter_date, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(facility_letter_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a facility letter date before a specified date" do
      loan1.update_attribute(:facility_letter_date, 1.day.ago)
      loan2.update_attribute(:facility_letter_date, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(facility_letter_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a created at date after a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(created_at_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a created at date before a specified date" do
      loan1.update_attribute(:created_at, 1.day.ago)
      loan2.update_attribute(:created_at, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(created_at_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a modified at date after a specified date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(last_modified_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a modified at date before a specified date" do
      loan1.update_attribute(:updated_at, 1.day.ago)
      loan2.update_attribute(:updated_at, 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(last_modified_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans belonging to a specific lender" do
      loan_report = LoanReport.new(
        report_attributes(
          allowed_lender_ids: [ loan1.lender_id ],
          lender_ids: [ loan1.lender_id ]
        )
      )

      loan_report.loans.should == [ loan1 ]
    end

    context 'with loans created by specific users' do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      before(:each) do
        loan1.update_attribute(:created_by, user1)
        loan2.update_attribute(:created_by, user2)
      end

      it "should return loans created by a specific user" do
        loan_report = LoanReport.new(report_attributes(created_by_id: user2.id))
        loan_report.loans.should == [ loan2 ]
      end

      it "should return no loans when specified created by user does not belong to one of the specified lenders" do
        loan_report = LoanReport.new(
          report_attributes(
            allowed_lender_ids: [ loan1.lender_id ],
            lender_ids: [ loan1.lender_id ],
            created_by_id: user2.id
          )
        )

        loan_report.loans.should be_empty
      end
    end

    it "should ignore blank values" do
      loan_report = LoanReport.new(report_attributes(facility_letter_start_date: ""))
      loan_report.loans.should == [ loan1, loan2 ]
    end

  end

  private

  def report_attributes(params = {})
    allowed_lender_ids = Lender.count.zero? ? [ 1 ] : Lender.all.collect(&:id)
    lender_ids = Lender.count.zero? ? [ 1 ] : Lender.all.collect(&:id)

    FactoryGirl.attributes_for(
      :loan_report,
      allowed_lender_ids: allowed_lender_ids,
      lender_ids: lender_ids
    ).merge(params)
  end

end
