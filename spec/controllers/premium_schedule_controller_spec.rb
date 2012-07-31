require 'spec_helper'

describe PremiumScheduleController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }

  describe '#show' do
    def dispatch(params = {})
      get :show, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumScheduleCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'
  end
end
