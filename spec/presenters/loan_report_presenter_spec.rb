require 'spec_helper'
require 'csv'

describe LoanReportPresenter do

  describe "#initialize" do
    let(:user) { double('user') }

    it "should not allow unsupported attributes" do
      expect {
        LoanReportPresenter.new(user, report_attributes(company_registration: '123456C'))
      }.to raise_error(NoMethodError)
    end
  end

  describe "validation" do
    let(:user) { double('user') }
    let(:loan_report_presenter) { LoanReportPresenter.new(user, report_attributes) }

    it 'should have a valid factory' do
      loan_report_presenter.should be_valid
    end

    it 'should be invalid without an allowed loan state' do
      loan_report_presenter.states = [ "wrong" ]
      loan_report_presenter.should_not be_valid

      loan_report_presenter.states = [ Loan::Guaranteed ]
      loan_report_presenter.should be_valid
    end

    it 'should be invalid without numeric created by user ID' do
      loan_report_presenter.created_by_id = 'a'
      loan_report_presenter.should_not be_valid
    end

    it 'should be valid with blank created by user ID' do
      loan_report_presenter.created_by_id = ''
      loan_report_presenter.should be_valid
    end

    it 'should be invalid without a loan source' do
      loan_report_presenter.loan_sources = nil
      loan_report_presenter.should_not be_valid
    end

    it 'should be invalid without an allowed loan source' do
      loan_report_presenter.loan_sources = ["Z"]
      loan_report_presenter.should_not be_valid

      loan_report_presenter.loan_sources = [ Loan::LEGACY_SFLG_SOURCE ]
      loan_report_presenter.should be_valid
    end

    it 'should be valid when loan scheme is nil' do
      loan_report_presenter.loan_scheme = nil
      loan_report_presenter.should be_valid
    end

    it 'should be valid with a blank loan scheme' do
      loan_report_presenter.loan_scheme = ""
      loan_report_presenter.should be_valid
    end

    it 'should be invalid without an allowed loan scheme' do
      loan_report_presenter.loan_scheme = "Z"
      loan_report_presenter.should_not be_valid

      loan_report_presenter.loan_scheme = Loan::EFG_SCHEME
      loan_report_presenter.should be_valid
    end

    it 'should be invalid without lender IDs' do
      loan_report_presenter.lender_ids = nil
      loan_report_presenter.should_not be_valid
    end

    it 'should be invalid without a numeric created by ID' do
      loan_report_presenter.created_by_id = 'a'
      loan_report_presenter.should_not be_valid
    end

    it "should raise exception when a specified lender is not allowed" do
      loan1 = FactoryGirl.create(:loan, :eligible)
      loan2 = FactoryGirl.create(:loan, :guaranteed)

      loan_report_presenter.allowed_lender_ids = [ loan2.lender_id ]
      loan_report_presenter.lender_ids         = [ loan1.lender_id, loan2.lender_id ]

      expect {
        loan_report_presenter.valid?
      }.to raise_error(LoanReportPresenter::LenderNotAllowed)
    end
  end

  describe "delegating to report" do
    let(:user) { double('user')}
    let(:loan_report) { double('LoanReport') }
    let(:presenter) { LoanReportPresenter.new(user) }
    before { presenter.stub!(:report).and_return(loan_report) }

    it "delegates #count" do
      loan_report.should_receive(:count).and_return(45)
      presenter.count.should == 45
    end

    it "delgates #loans" do
      loans = double('loans')
      loan_report.should_receive(:loans).and_return(loans)
      presenter.loans.should == loans
    end
  end

  describe "permissions" do
    let(:presenter) { LoanReportPresenter.new(user) }

    context "with AuditorUser" do
      let(:user) { FactoryGirl.build(:auditor_user) }

      it "allows lender selection" do
        presenter.should have_lender_selection
      end

      it "doesn't allow created by selection" do
        presenter.should_not have_created_by_selection
      end
    end

    context "with CfeUser" do
      let(:user) { FactoryGirl.build(:cfe_user) }

      it "allows lender selection" do
        presenter.should have_lender_selection
      end

      it "allows loan type selection" do
        presenter.should have_loan_type_selection
      end

      it "doesn't allow created by selection" do
        presenter.should_not have_created_by_selection
      end
    end

    context "with LenderUser" do
      let(:user) { FactoryGirl.build(:lender_user) }

      it "doesn't allow lender selection" do
        presenter.should_not have_lender_selection
      end

      it "allows created by selection" do
        presenter.should have_created_by_selection
      end
    end

    context "with a users's 'lender' that can access all loan schemes" do
      let(:lender) { double('lender', :can_access_all_loan_schemes? => true)}
      let(:user) { FactoryGirl.build(:lender_user) }
      before { user.stub!(:lender).and_return(lender) }

      it "allows loan type selection" do
        presenter.should have_loan_type_selection
      end
    end

    context "with a user's 'lender' that can't access all loan schemes" do
      let(:lender) { double('lender', :can_access_all_loan_schemes? => false)}
      let(:user) { FactoryGirl.build(:lender_user) }
      before { user.stub!(:lender).and_return(lender) }

      it "doesn't allow loan type selection" do
        presenter.should_not have_loan_type_selection
      end
    end
  end

  private

  def report_attributes(params = {})
    allowed_lender_ids = Lender.count.zero? ? [ 1 ] : Lender.all.collect(&:id)
    lender_ids = Lender.count.zero? ? [ 1 ] : Lender.all.collect(&:id)

    {
      allowed_lender_ids: allowed_lender_ids,
      lender_ids: lender_ids,
      loan_sources: [Loan::SFLG_SOURCE],
      loan_scheme: Loan::EFG_SCHEME,
      states: Loan::States,
    }.merge(params)
  end

end
