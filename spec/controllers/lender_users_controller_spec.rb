require 'spec_helper'

describe LenderUsersController do
  let(:lender) { FactoryGirl.create(:lender) }

  describe '#index' do
    def dispatch
      get :index, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      get :show, id: lender_user.id, lender_id: lender_user.lender.id
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
      get :new, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      post :create, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#edit' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      get :edit, id: lender_user.id, lender_id: lender_user.lender.id
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
      put :update, id: lender_user.id, lender_id: lender_user.lender.id
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
      post :reset_password, id: lender_user.id, lender_id: lender_user.lender.id
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
      post :unlock, id: lender_user.id, lender_id: lender_user.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#disable' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      post :disable, id: lender_user.id, lender_id: lender_user.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#enable' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }

    def dispatch
      post :enable, id: lender_user.id, lender_id: lender_user.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
