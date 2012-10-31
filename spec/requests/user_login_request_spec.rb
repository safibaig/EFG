require 'spec_helper'

describe 'user login' do
  describe 'Account locking' do
    let(:user) { FactoryGirl.create(:lender_user) }

    it 'should lock a user account after a number of failed login attempts' do
      visit root_path

      unsuccessfully_login_until_locked(user)

      # incorrect authentication details for locked account shows generic flash message
      unsuccessfully_login(user)
      page.should have_content(I18n.t('devise.failure.locked'))

      # correct authentication details allows login
      # but all pages redirect to page informing user their account is locked
      submit_sign_in_form user.username, 'password'
      page.should have_content('Your account has been locked')
      page.current_path.should == account_locked_path

      # check other pages aren't accessible
      visit loan_states_path
      page.should have_content('Your account has been locked')
      page.current_path.should == account_locked_path
    end

    it 'should reset failed attempts after successfully logging into unlocked account' do
      failed_login_attempts = Devise.maximum_attempts - 1

      visit root_path

      # failed login
      failed_login_attempts.times do
        submit_sign_in_form user.username, 'wrong!'
      end

      user.reload
      user.failed_attempts.should == failed_login_attempts

      successfully_login(user)

      user.reload
      user.failed_attempts.should == 0
    end

    it 'should not reset failed attempts after successfully logging into locked account' do
      visit root_path

      unsuccessfully_login_until_locked(user)

      user.reload
      user.failed_attempts.should_not == 0

      successfully_login(user)
      page.should have_content('Your account has been locked')

      user.reload
      user.failed_attempts.should_not == 0
    end
  end

  describe 'as a user belonging to a disabled lender' do
    shared_examples 'disabled lender login' do
      it 'should be able to login' do
        visit root_path
        submit_sign_in_form user.username, 'password'
        page.should have_content(I18n.t('devise.failure.invalid'))
      end
    end

    let(:lender) { FactoryGirl.create(:lender, disabled: true) }

    context 'LenderAdmin' do
      it_should_behave_like 'disabled lender login' do
        let(:user) { FactoryGirl.create(:lender_admin, lender: lender) }
      end
    end

    context 'LenderUser' do
      it_should_behave_like 'disabled lender login' do
        let(:user) { FactoryGirl.create(:lender_user, lender: lender) }
      end
    end
  end

  def successfully_login(user)
    submit_sign_in_form(user.username, user.password)
  end

  def unsuccessfully_login(user)
    submit_sign_in_form(user.username, 'wrong!')
  end

  def unsuccessfully_login_until_locked(user)
    (Devise.maximum_attempts + 1).times do
      unsuccessfully_login(user)
    end
  end

end
