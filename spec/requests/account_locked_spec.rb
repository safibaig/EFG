require 'spec_helper'

describe 'Account locking' do

  let(:lender_user) { FactoryGirl.create(:lender_user) }

  it 'should lock a user account after a number of failed login attempts' do
    visit root_path

    (Devise.maximum_attempts + 1).times do
      fill_in 'user_username', with: lender_user.username
      fill_in 'user_password', with: 'wrong!'
      click_button 'Sign In'
    end

    # correct authentication details, but account is now locked...
    fill_in 'user_username', with: lender_user.username
    fill_in 'user_password', with: 'password'
    click_button 'Sign In'

    page.should have_content(I18n.t('devise.failure.locked'))
    page.current_path.should == user_session_path
  end

end
