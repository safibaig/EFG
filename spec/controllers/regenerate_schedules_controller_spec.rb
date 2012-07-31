require 'spec_helper'

describe RegenerateSchedulesController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumScheduleCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, state_aid_calculation: {} }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumScheduleCollectorUser-restricted controller'
    it_behaves_like 'Lender-scoped controller'
  end
end
