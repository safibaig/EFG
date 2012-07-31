require 'spec_helper'

describe LoanRemoveGuaranteesController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-only controller'
    it_behaves_like 'PremiumScheduleCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, loan_remove_guarantee: {} }.merge(params)
    end

    it_behaves_like 'CfeUser-only controller'
    it_behaves_like 'PremiumScheduleCollectorUser-restricted controller'
  end
end
