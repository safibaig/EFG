require 'spec_helper'

describe LenderUsersController do
  describe '#index' do
    def dispatch
      get :index
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      get :show, id: lender_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#new' do
    def dispatch
      get :new
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      post :create
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#edit' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      get :edit, id: lender_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#update' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      put :update, id: lender_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#reset_password' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      post :reset_password, id: lender_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#unlock' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      post :unlock, id: lender_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
