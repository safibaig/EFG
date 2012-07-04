require 'spec_helper'

describe LoanOffersController do
  describe '#new' do
    let(:loan) { FactoryGirl.create(:loan, :completed) }

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

    let(:loan_offer) { double(LoanOffer, loan: loan, :attributes= => nil, save: false) }
    before { LoanOffer.stub!(:new).and_return(loan_offer) }

    def dispatch(parameters = {})
      default_parameters = {loan_id: loan.id, loan_offer: {}}
      post :create, default_parameters.merge(parameters)
    end

    context "with a loan from the current lender" do
      let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_lender) }

      context "with a valid loan offer" do
        before { loan_offer.stub!(:save).and_return(true) }

        it "should redirect to the loan page" do
          dispatch
          response.should redirect_to(loan_url(loan))
        end
      end

      context "with an invalid loan offer" do
        before { loan_offer.stub!(:save).and_return(false) }

        it "should render new" do
          dispatch
          response.should render_template(:new)
        end
      end
    end

    context "with a loan from another lender" do
      let(:other_lender) { FactoryGirl.create(:lender) }
      let(:loan) { FactoryGirl.create(:loan, :completed, lender: other_lender) }

      it "raises RecordNotFound for a loan from another lender" do
        expect {
          dispatch
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
