require 'spec_helper'

describe 'Change password' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  before { login_as(current_user, scope: :user) }

  it "should update a user's password" do
    visit root_path
    click_link 'Change Password'

    fill_in 'user_password', with: 'new-password'
    fill_in 'user_password_confirmation', with: 'new-password'
    click_button 'Update Password'

    page.should have_content('Your password has been successfully changed')

    # sign in with new password

    click_link "Logout"
    fill_in 'user_username', with: lender_admin.username
    fill_in 'user_password', with: 'new-password'
    click_button 'Sign In'

    page.should have_content(I18n.t('devise.sessions.signed_in'))
  end

end
