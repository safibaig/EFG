require 'spec_helper'

describe 'Contact support' do

  before do
    ActionMailer::Base.deliveries.clear
    login_as(current_user, scope: :user)
  end

  context 'as a Lender User' do
    let!(:current_user) { FactoryGirl.create(:lender_user) }

    let!(:lender_admin1) { FactoryGirl.create(:lender_admin, lender: current_user.lender) }

    let!(:lender_admin2) { FactoryGirl.create(:lender_admin, lender: current_user.lender) }

    let!(:a_different_lender_admin) { FactoryGirl.create(:lender_admin) }

    it "should send email to their lender's admins" do
      navigate_to_contact_support_form
      send_support_request

      ActionMailer::Base.deliveries.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == [ lender_admin1.email, lender_admin2.email ]
    end
  end

  context 'as a Lender Admin' do
    let!(:current_user) { FactoryGirl.create(:lender_admin) }

    let!(:cfe_user1) { FactoryGirl.create(:cfe_user) }

    let!(:cfe_user2) { FactoryGirl.create(:cfe_user) }

    it 'should send email to CfE users' do
      navigate_to_contact_support_form
      send_support_request

      ActionMailer::Base.deliveries.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == [ cfe_user1.email, cfe_user2.email ]
    end
  end

  context 'as a CfE User' do
    let!(:current_user) { FactoryGirl.create(:cfe_user) }

    let!(:super_user1) { FactoryGirl.create(:super_user) }

    let!(:super_user2) { FactoryGirl.create(:super_user) }

    it 'should send email to super users' do
      navigate_to_contact_support_form
      send_support_request

      ActionMailer::Base.deliveries.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == [ super_user1.email, super_user2.email ]
    end
  end

  private

  def navigate_to_contact_support_form
    visit root_path
    click_link 'Contact Support'
  end

  def send_support_request
    fill_in "support_request_message", with: "HELP!!!!"
    click_button "Contact Support"
    page.should have_content(I18n.t('support_request.request_sent'))
  end

end
