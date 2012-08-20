require 'spec_helper'

describe 'Resetting password' do

  let!(:user) {
    FactoryGirl.create(
      :lender_user,
      reset_password_token: 'abc123',
      reset_password_sent_at: 1.minute.ago
    )
  }

  it 'sends email to correct user when email address belongs to more than one account' do
    ActionMailer::Base.deliveries.clear
    user1 = FactoryGirl.create(:lender_user, email: 'joe1@example.com', username: 'joe1')
    user2 = FactoryGirl.create(:auditor_user, email: 'joe1@example.com', username: 'joe2')

    visit new_user_password_path
    fill_in 'user_username', with: 'joe2'
    click_button 'Send Reset Instructions'

    page.should have_content(I18n.t('devise.passwords.send_paranoid_instructions'))

    user2.reload
    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.should == [ user2.email ]
    emails.first.body.match(/#{user2.reset_password_token}/)
  end

  it 'can successfully reset password' do
    open_reset_password_page
    submit_change_password_form

    page.should have_content(I18n.t('devise.passwords.updated'))
  end

  it 'fails when allowed time has expired' do
    user.reset_password_sent_at = LenderUser.reset_password_within.ago - 1.second
    user.save!

    open_reset_password_page
    submit_change_password_form

    page.should have_content('Reset password token has expired, please request a new one')
  end

  it 'fails with invalid token' do
    open_reset_password_page(reset_password_token: 'wrong')
    submit_change_password_form

    page.should have_content('Reset password token is invalid')
  end

  private

  def open_reset_password_page(params = {})
    visit edit_user_password_path({ reset_password_token: user.reset_password_token }.merge(params))
  end

  def submit_change_password_form
    fill_in 'user[password]', with: 'new-password'
    fill_in 'user[password_confirmation]', with: 'new-password'
    click_button 'Change Password'
  end

end
