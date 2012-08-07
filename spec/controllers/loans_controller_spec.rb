require 'spec_helper'

describe LoansController do
  describe '#show' do
    let(:loan) { FactoryGirl.create(:loan) }

    def dispatch(params = {})
      get :show, { id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it do
        dispatch
        response.should be_success
      end
    end
  end
end
