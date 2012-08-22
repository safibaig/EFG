require 'spec_helper'

describe "Session timeout" do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  before do
    login_as(current_user, scope: :user)
  end

  it 'should redirect a user to the login page after a period of inactivity' do
    visit root_path
    page.current_path.should == root_path

    timeout_user_session!

    visit root_path
    page.current_path.should == new_user_session_path
  end

  private

  def timeout_user_session!
    Warden::Proxy.any_instance.stub(:session).
      and_return({ 'last_request_at' => (Devise.timeout_in + 1.second).ago })
  end

end
