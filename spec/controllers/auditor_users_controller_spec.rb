require 'spec_helper'

describe AuditorUsersController do
  describe '#index' do
    def dispatch
      get :index
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      get :show, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#new' do
    def dispatch
      get :new
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      post :create
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#edit' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      get :edit, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#update' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      put :update, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#reset_password' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      post :reset_password, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#unlock' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      post :unlock, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#disable' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      post :disable, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#enable' do
    let(:auditor_user) { FactoryGirl.create(:auditor_user) }

    def dispatch
      post :enable, id: auditor_user.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
