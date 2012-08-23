require 'spec_helper'

describe 'Account locking' do

  let(:lender_user) { FactoryGirl.create(:lender_user) }

  it 'should lock a user account after a number of failed login attempts' do
    visit root_path

    (Devise.maximum_attempts + 1).times do
      submit_sign_in_form('wrong!')
    end

    # incorrect authentication details for locked account shows generic flash message
    submit_sign_in_form('wrong!')
    page.should have_content(I18n.t('devise.failure.locked'))

    # correct authentication details allows login
    # but all pages redirect to page informing user their account is locked
    submit_sign_in_form('password')
    page.should have_content('Your account has been locked')
    page.current_path.should == account_locked_path

    # check other pages aren't accessible
    visit loan_states_path
    page.should have_content('Your account has been locked')
    page.current_path.should == account_locked_path
  end

  private

  def submit_sign_in_form(password)
    fill_in 'user_username', with: lender_user.username
    fill_in 'user_password', with: password
    click_button 'Sign In'
  end

end
