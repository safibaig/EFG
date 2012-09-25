require 'spec_helper'

describe 'ask CfE' do
  before do
    ActionMailer::Base.deliveries.clear
    login_as(current_user, scope: :user)
  end

  context 'as an Auditor' do
    let(:current_user) { FactoryGirl.create(:auditor_user) }

    before do
      visit root_path
      click_link 'Ask CfE'
    end

    it 'works' do
      fill_in 'ask_cfe_message', with: 'blah blah'
      click_button 'Submit'
      ActionMailer::Base.deliveries.size.should == 1
      page.should have_content('Thanks')
    end

    it 'does nothing with no message' do
      click_button 'Submit'
      ActionMailer::Base.deliveries.size.should == 0
    end
  end
end
