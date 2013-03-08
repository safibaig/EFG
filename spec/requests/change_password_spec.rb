require 'spec_helper'

describe 'Change password' do

  %w(
    auditor_user
    cfe_admin
    cfe_user
    lender_admin
    lender_user
    premium_collector_user
  ).each do |user_type|

    it "should allow a #{user_type.humanize} to update their password" do
      current_user = FactoryGirl.create(user_type)
      login_as(current_user, scope: :user)

      visit root_path
      visit edit_change_password_path
      click_link 'Change Password'

      fill_in "#{user_type}_password", with: 'new-password'
      fill_in "#{user_type}_password_confirmation", with: 'new-password'
      click_button 'Update Password'

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserPasswordChanged
      admin_audit.auditable.should == current_user
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current

      page.should have_content('Your password has been successfully changed')
      page.current_url.should == root_url

      # sign in with new password

      click_link "Logout"
      fill_in 'user_username', with: current_user.username
      fill_in 'user_password', with: 'new-password'
      click_button 'Sign In'

      page.should have_content(I18n.t('devise.sessions.signed_in'))
      page.current_url.should == root_url
    end

    it "should not allow weak passwords" do
      current_user = FactoryGirl.create(user_type)
      login_as(current_user, scope: :user)

      visit root_path
      visit edit_change_password_path
      click_link 'Change Password'

      fill_in "#{user_type}_password", with: 'password'
      fill_in "#{user_type}_password_confirmation", with: 'password'
      click_button 'Update Password'

      page.should have_content(I18n.t('errors.messages.insufficient_entropy', entropy: 5, minimum_entropy: Devise::Models::Strengthened::MINIMUM_ENTROPY))
    end

  end

  it 'cannot be accessed unless logged in' do
    visit edit_change_password_path
    page.should have_content(I18n.t('devise.failure.unauthenticated'))
  end

end
