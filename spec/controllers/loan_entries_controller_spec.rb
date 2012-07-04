require 'spec_helper'

describe LoanEntriesController do
  describe '#new' do
    let(:loan) { FactoryGirl.create(:loan) }

    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#create' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
    before { sign_in(current_user) }

    let(:loan_entry) { double(LoanEntry, loan: loan, :attributes= => nil, save: false)}
    before { LoanEntry.stub!(:new).and_return(loan_entry) }

    def dispatch(parameters = {})
      default_parameters = {loan_id: loan.id, loan_entry: {}}
      post :create, default_parameters.merge(parameters)
    end

    context "with a loan from the same lender" do
      let(:loan) { FactoryGirl.create(:loan, lender: current_lender) }

      context "when submitting a valid loan" do
        before { loan_entry.stub!(:save).and_return(true) }

        def dispatch(parameters = {})
          super(commit: 'Submit')
        end

        it "should redirect to the loan page" do
          dispatch
          response.should redirect_to(loan_url(loan))
        end
      end

      context "when submitting an invalid loan" do
        before { loan_entry.stub!(:save).and_return(false) }

        def dispatch(parameters = {})
          super(commit: 'Submit')
        end

        it "should render new action" do
          dispatch
          response.should render_template(:new)
        end
      end
    end

    context "with a loan from another lender" do
      let(:other_lender) { FactoryGirl.create(:lender) }
      let(:loan) { FactoryGirl.create(:loan, lender: other_lender) }

      it "raises RecordNotFound" do
        expect {
          dispatch
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
