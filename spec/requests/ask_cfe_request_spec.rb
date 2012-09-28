require 'spec_helper'

describe 'ask CfE' do
  before do
    ActionMailer::Base.deliveries.clear
    login_as(current_user, scope: :user)
    visit root_path
    click_link 'Ask CfE'
  end

  [
    :auditor_user,
    :expert_lender_admin,
    :expert_lender_user,
    :premium_collector_user
  ].each do |type|
    context "as a #{type}" do
      let(:current_user) { FactoryGirl.create(type) }

      it 'works' do
        fill_in 'ask_cfe_message', with: 'blah blah'
        click_button 'Submit'

        ActionMailer::Base.deliveries.size.should == 1

        email = ActionMailer::Base.deliveries.last
        email.reply_to.should == [current_user.email]
        email.body.should include('blah blah')
        email.body.should include(current_user.name)

        page.should have_content('Thanks')
      end
    end
  end

  context 'with invalid values' do
    let(:current_user) { FactoryGirl.create(:auditor_user) }

    it 'does nothing' do
      click_button 'Submit'
      ActionMailer::Base.deliveries.size.should == 0
    end
  end
end
