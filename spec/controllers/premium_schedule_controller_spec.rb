require 'spec_helper'

describe PremiumScheduleController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }

  describe '#show' do
    def dispatch(params = {})
      get :show, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
