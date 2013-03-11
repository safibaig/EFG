require 'spec_helper'

describe 'Resetting password' do

  let(:user) {
    FactoryGirl.create(
      :lender_user,
      reset_password_token: 'abc123',
      reset_password_sent_at: 1.minute.ago
    )
  }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'sends email to correct user when email address belongs to more than one account' do
    user1 = FactoryGirl.create(:lender_user, email: 'joe1@example.com', username: 'joe1')
    user2 = FactoryGirl.create(:auditor_user, email: 'joe1@example.com', username: 'joe2', locked: true)

    visit new_user_password_path
    fill_in 'user_username', with: 'joe2'
    click_button 'Send Reset Instructions'

    page.should have_content(I18n.t('devise.passwords.send_paranoid_instructions'))

    user2.reload
    user2.locked.should == false

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.should == [ user2.email ]
    emails.first.body.should include(user2.reset_password_token)
  end

  it 'does not work if the user has no email' do
    user = FactoryGirl.build(:lender_user, email: nil, username: 'bob')
    user.save(validate: false)

    visit new_user_password_path
    fill_in 'user_username', with: 'bob'
    click_button 'Send Reset Instructions'

    ActionMailer::Base.deliveries.size.should == 0
    page.should have_content(I18n.t('devise.passwords.send_paranoid_instructions'))
  end

  it 'can successfully reset password' do
    open_reset_password_page
    submit_change_password_form

    page.should have_content(I18n.t('devise.passwords.updated'))
  end

  it 'fails when changed password is too weak' do
    open_reset_password_page
    submit_change_password_form 'password'
    page.should have_content(I18n.t('errors.messages.insufficient_entropy', entropy: 5, minimum_entropy: Devise::Models::Strengthened::MINIMUM_ENTROPY))
  end

  it 'fails when allowed time has expired' do
    user.reset_password_sent_at = LenderUser.reset_password_within.ago - 1.second
    user.save!

    open_reset_password_page
    submit_change_password_form

    page.should have_content('Reset password token has expired')
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

  def submit_change_password_form(new_password = 'new-password-W1bbL3')
    fill_in 'user[password]', with: new_password
    fill_in 'user[password_confirmation]', with: new_password
    click_button 'Change Password'
  end

end
