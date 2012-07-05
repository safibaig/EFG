require 'spec_helper'

describe EligibilityChecksController do
  describe '#new' do
    def dispatch(params = {})
      get :new, params
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_eligibility_check: {} }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
  end
end
