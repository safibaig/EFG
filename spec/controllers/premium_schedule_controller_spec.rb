require 'spec_helper'

describe PremiumScheduleController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }

  describe '#show' do
    def dispatch(params = {})
      get :show, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'
  end
end
