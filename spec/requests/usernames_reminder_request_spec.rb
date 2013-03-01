require 'spec_helper'

describe 'Sending usernames reminder' do
  before do
    visit root_path
    click_link 'Forgot your username?'
  end

  context 'when a matching user exists' do
    let!(:user) { FactoryGirl.create(:lender_user,
                                    username: 'user1',
                                    email: 'user1@example.com')
    }

    it 'displays a flash message stating that an email may have been sent' do
      fill_in 'Email', with: user.email
      click_button 'Send Username Reminder'

      page.should have_content(I18n.t('manage_users.usernames_reminder_sent'))
    end
  end

  context 'when no matching user exists' do
    it 'displays a flash message stating that an email may have been sent' do
      fill_in 'Email', with: 'no_such_user@example.com'
      click_button 'Send Username Reminder'

      page.should have_content(I18n.t('manage_users.usernames_reminder_sent'))
    end
  end
end
