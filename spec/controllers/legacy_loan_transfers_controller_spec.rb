require 'spec_helper'

describe LegacyLoanTransfersController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, :legacy_sflg) }

  describe '#show' do
    def dispatch(params = {})
      get :show, id: loan.id
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#new' do
    def dispatch(params = {})
      get :new
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'

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
    def dispatch
      post :create, loan_transfer: {}
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
  end
end
