require 'spec_helper'

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

    it 'should be invalid without a loan state' do
      loan_report.state = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan state' do
      loan_report.state = "wrong"
      loan_report.should_not be_valid

      loan_report.state = "All"
      loan_report.should be_valid
    end

    it 'should be invalid without created by user ID' do
      pending
      loan_report.created_by_user_id = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without a loan type' do
      loan_report.loan_source = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan type' do
      loan_report.loan_source = "Z"
      loan_report.should_not be_valid

      loan_report.loan_source = Loan::LEGACY_SFLG_SOURCE
      loan_report.should be_valid
    end

    it 'should be invalid without a loan scheme' do
      loan_report.loan_scheme = nil
      loan_report.should_not be_valid
    end

    it 'should be invalid without an allowed loan scheme' do
      loan_report.loan_scheme = "Z"
      loan_report.should_not be_valid

      loan_report.loan_scheme = Loan::EFG_SCHEME
      loan_report.should be_valid
    end

    it 'should be invalid without lender ID' do
      loan_report.lender_id = nil
      loan_report.should_not be_valid
    end

    %w(
      facility_letter_start_date
      facility_letter_end_date
      created_at_start_date
      created_at_end_date
      last_modified_start_date
      last_modified_end_date
    ).each do |field|
      it "should be invalid without a correctly formatted #{field.humanize}" do
        loan_report.send("#{field}=", '2008/01/01')
        loan_report.should_not be_valid

        loan_report.send("#{field}=", '18/06/2012')
        loan_report.should be_valid
      end
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
      loan_report.state = Loan::Guaranteed
      loan_report.count.should == 2
    end

  end

  describe "#loans" do

    let(:loan_report) { LoanReport.new(report_attributes) }

    it "should return all loans when matching the default report criteria" do
      loan1 = FactoryGirl.create(:loan)
      loan2 = FactoryGirl.create(:loan)

      loan_report.loans.should == [loan1, loan2]
    end

    it "should return loans with a specific state" do
      loan1 = FactoryGirl.create(:loan, :eligible)
      loan2 = FactoryGirl.create(:loan, :guaranteed)

      loan_report = LoanReport.new(report_attributes(state: Loan::Guaranteed))
      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a specific loan scheme" do
      loan1 = FactoryGirl.create(:loan, :sflg)
      loan2 = FactoryGirl.create(:loan)

      loan_report = LoanReport.new(report_attributes(loan_scheme: Loan::SFLG_SCHEME))
      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a specific loan source" do
      loan1 = FactoryGirl.create(:loan, loan_source: Loan::LEGACY_SFLG_SOURCE)
      loan2 = FactoryGirl.create(:loan)

      loan_report = LoanReport.new(report_attributes(loan_source: Loan::LEGACY_SFLG_SOURCE))
      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a facility letter date after a specified date" do
      loan1 = FactoryGirl.create(:loan, facility_letter_date: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, facility_letter_date: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(facility_letter_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a facility letter date before a specified date" do
      loan1 = FactoryGirl.create(:loan, facility_letter_date: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, facility_letter_date: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(facility_letter_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a created at date after a specified date" do
      loan1 = FactoryGirl.create(:loan, created_at: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, created_at: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(created_at_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a created at date before a specified date" do
      loan1 = FactoryGirl.create(:loan, created_at: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, created_at: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(created_at_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans with a modified at date after a specified date" do
      loan1 = FactoryGirl.create(:loan, updated_at: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, updated_at: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(last_modified_start_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan2 ]
    end

    it "should return loans with a modified at date before a specified date" do
      loan1 = FactoryGirl.create(:loan, updated_at: 1.day.ago)
      loan2 = FactoryGirl.create(:loan, updated_at: 1.day.from_now)

      loan_report = LoanReport.new(report_attributes(last_modified_end_date: Date.today.strftime('%d/%m/%Y')))

      loan_report.loans.should == [ loan1 ]
    end

    it "should return loans belonging to a specific lender" do
      loan1 = FactoryGirl.create(:loan)
      loan2 = FactoryGirl.create(:loan)

      loan_report = LoanReport.new(report_attributes(lender_id: loan1.lender_id))

      loan_report.loans.should == [ loan1 ]
    end

    it "should ignore blank values" do
      loan1 = FactoryGirl.create(:loan)
      loan2 = FactoryGirl.create(:loan)

      loan_report = LoanReport.new(report_attributes(facility_letter_start_date: ""))

      loan_report.loans.should == [ loan1, loan2 ]
    end

  end

  private

  def report_attributes(params = {})
    FactoryGirl.attributes_for(:loan_report).merge(params)
  end

end
