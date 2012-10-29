require 'spec_helper'

describe LoanGuaranteesController do
  let(:loan) { FactoryGirl.create(:loan, :offered) }

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'rescue_from LoanStateTransition::IncorrectLoanState controller'
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, loan_guarantee: {} }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
    it_behaves_like 'rescue_from LoanStateTransition::IncorrectLoanState controller'
  end
end
