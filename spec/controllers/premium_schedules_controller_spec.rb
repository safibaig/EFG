require 'spec_helper'

describe PremiumSchedulesController do
  let(:loan) { FactoryGirl.create(:loan, :eligible) }

  describe '#edit' do
    def dispatch(params = {})
      get :edit, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    def dispatch(params = {})
      get :show, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#update' do
    def dispatch(params = {})
      put :update, { loan_id: loan.id, premium_schedule: {} }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
