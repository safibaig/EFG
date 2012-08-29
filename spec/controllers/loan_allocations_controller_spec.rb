require 'spec_helper'

describe LoanAllocationsController do
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
    let(:loan_allocation) { FactoryGirl.create(:loan_allocation) }

    def dispatch
      get :edit, lender_id: lender.id, id: loan_allocation.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'PUT update' do
    let(:loan_allocation) { FactoryGirl.create(:loan_allocation, description: 'foo', starts_on: '1/1/11') }

    def dispatch
      put :update, lender_id: lender.id, id: loan_allocation.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
