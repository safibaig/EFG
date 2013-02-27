require 'spec_helper'

describe LoanAlertsController do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  before { sign_in(current_user) }

  describe "not_drawn" do
    def dispatch
      get :show, id: 'not_drawn'
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "not_demanded" do
    def dispatch
      get :show, id: 'not_demanded'
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "not_progressed" do
    def dispatch
      get :show, id: 'not_progressed'
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "not_closed" do
    def dispatch
      get :show, id: 'not_closed'
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe 'unknown alert action' do
    def dispatch
      get :show, id: 'foo'
    end

    it 'behaves like a DB-backed action' do
      expect {
        dispatch
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
