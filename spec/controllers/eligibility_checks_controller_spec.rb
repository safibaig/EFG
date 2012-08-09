require 'spec_helper'

describe EligibilityChecksController do
  describe '#new' do
    def dispatch(params = {})
      get :new, params
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_eligibility_check: FactoryGirl.attributes_for(:loan_eligibility_check) }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'as logged in lender user' do
      let(:current_user) { FactoryGirl.create(:lender_user) }

      before do
        sign_in current_user
      end

      it 'should set loan scheme to "E"' do
        dispatch
        Loan.last.loan_scheme.should == Loan::EFG_SCHEME
      end

      it 'should set loan source to "S"' do
        dispatch
        Loan.last.loan_source.should == Loan::SFLG_SOURCE
      end

    end
  end
end
