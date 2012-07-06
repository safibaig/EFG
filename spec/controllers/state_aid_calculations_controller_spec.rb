require 'spec_helper'

describe StateAidCalculationsController do
  let(:loan) { FactoryGirl.create(:loan, :eligible) }

  describe '#edit' do
    def dispatch(params = {})
      get :edit, { loan_id: loan.id }.merge(params)
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

  describe '#update' do
    def dispatch(params = {})
      put :update, { loan_id: loan.id, state_aid_calculation: {} }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'
  end
end
