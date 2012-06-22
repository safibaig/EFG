require 'spec_helper'

describe DocumentsController do

  let(:current_lender) { FactoryGirl.create(:lender) }

  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  before { sign_in(current_user) }

  describe '#state_aid_letter' do

    def dispatch(params)
      get :state_aid_letter, params
    end

    it_behaves_like 'documents controller action'
  end

  describe '#information_declaration' do

    def dispatch(params)
      get :information_declaration, params
    end

    it_behaves_like 'documents controller action'
  end

end
