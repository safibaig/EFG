require 'spec_helper'

describe 'Resetting password' do

  let!(:user) {
    FactoryGirl.create(
      :lender_user,
      reset_password_token: 'abc123',
      reset_password_sent_at: 1.minute.ago
    )
  }

  it 'can successfully reset password' do
    open_reset_password_page
    submit_change_password_form

    page.should have_content('Your password was changed successfully. You are now signed in.')
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
