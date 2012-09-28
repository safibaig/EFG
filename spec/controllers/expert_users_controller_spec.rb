require 'spec_helper'

describe ExpertUsersController do
  describe '#index' do
    def dispatch
      get :index
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, params
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'as a LenderAdmin' do
      let(:current_user) { FactoryGirl.create(:lender_admin) }
      before { sign_in(current_user) }

      it 'does nothing when a blank user_id is submitted' do
        expect {
          dispatch expert: { user_id: '' }
        }.to change(Expert, :count).by(0)
      end

      it 'does not create duplicate experts' do
        user = FactoryGirl.create(:lender_user, lender: current_user.lender)
        expert = FactoryGirl.create(:expert, user: user)

        expect {
          dispatch expert: { user_id: user.id }
        }.to change(Expert, :count).by(0)
      end

      it 'does not allow users of other lenders to be assigned' do
        user = FactoryGirl.create(:lender_user)

        expect {
          dispatch expert: { user_id: user.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#destroy' do
    let(:expert) { FactoryGirl.create(:expert) }

    def dispatch
      delete :destroy, id: expert.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
