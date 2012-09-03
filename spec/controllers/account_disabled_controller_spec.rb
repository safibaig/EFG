require 'spec_helper'

describe AccountDisabledController do

  let(:active_user) { FactoryGirl.create(:lender_user) }

  let(:disabled_user) { FactoryGirl.create(:lender_user, disabled: true) }

  describe '#show' do
    it 'should render when user is disabled' do
      sign_in(disabled_user)
      get :show
      response.should be_success
    end

    it 'should redirect to root path when user is not disabled' do
      sign_in(active_user)
      get :show
      response.should redirect_to(root_url)
    end
  end

end
