require 'spec_helper'

describe LendingLimitsController do
  let(:lender) { FactoryGirl.create(:lender) }

  describe 'GET index' do
    def dispatch
      get :index, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'GET new' do
    def dispatch
      get :new, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'POST create' do
    def dispatch
      post :create, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'GET edit' do
    let(:lending_limit) { FactoryGirl.create(:lending_limit) }

    def dispatch
      get :edit, lender_id: lender.id, id: lending_limit.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'PUT update' do
    let(:lending_limit) { FactoryGirl.create(:lending_limit, lender: lender, description: 'foo', starts_on: '1/1/11') }

    def dispatch(params = {})
      put :update, { lender_id: lender.id, id: lending_limit.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'as a CfeAdmin' do
      let(:current_user) { FactoryGirl.create(:cfe_admin) }
      before { sign_in(current_user) }

      it 'does not update starts_on attribute (amongst others)' do
        dispatch(lending_limit: { description: 'bar', starts_on: '2/2/12' })
        lending_limit.reload
        lending_limit.description.should == 'bar'
        lending_limit.starts_on.should == Date.new(2011, 1, 1)
      end
    end
  end
end
