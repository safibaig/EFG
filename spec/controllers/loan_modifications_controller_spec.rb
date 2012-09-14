require 'spec_helper'

describe LoanModificationsController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#index' do
    def dispatch(params = {})
      get :index, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#show' do
    let(:loan_change) { FactoryGirl.create(:loan_change, loan: loan) }

    def dispatch(params = {})
      get :show, { id: loan_change.id, loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
