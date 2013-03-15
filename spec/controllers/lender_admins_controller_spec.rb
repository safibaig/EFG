require 'spec_helper'

describe LenderAdminsController do
  let(:lender) { FactoryGirl.create(:lender) }

  describe '#index' do
    def dispatch
      get :index, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      get :show, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#new' do
    def dispatch
      get :new, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      post :create, lender_id: lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#edit' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      get :edit, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#update' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      put :update, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#reset_password' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      post :reset_password, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#unlock' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      post :unlock, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
  end

  describe '#disable' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      post :disable, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
  end

  describe '#enable' do
    let(:lender_admin) { FactoryGirl.create(:lender_admin) }

    def dispatch
      post :enable, id: lender_admin.id, lender_id: lender_admin.lender.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'LenderAdmin Lender-scoped controller'
  end
end
