require 'spec_helper'

describe RecoveriesController do
  let(:loan) { FactoryGirl.create(:loan, :settled) }

  shared_examples 'loan state restriction' do
    before { loan.update_attribute(:state, Loan::Eligible) }

    it do
      expect {
        dispatch
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it_behaves_like 'loan state restriction'

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, loan_repay: {} }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it_behaves_like 'loan state restriction'
    end
  end
end
