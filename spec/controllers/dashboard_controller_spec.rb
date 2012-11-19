require 'spec_helper'

describe DashboardController do
  describe "GET show" do
    context "with lender user" do
      let(:current_user) { FactoryGirl.create(:lender_user) }

      before { sign_in(current_user) }

      it "should render success" do
        get :show
        response.should be_success
      end
    end
  end
end
