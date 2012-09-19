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

      ActionMailer::Base.deliveries.size.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == [ lender_admin1.email, lender_admin2.email ]
    end

    it "with blank message" do
      navigate_to_contact_support_form
      click_button "Submit"

      page.should have_content "can't be blank"
      ActionMailer::Base.deliveries.should be_empty
    end
  end

  %w(
    auditor_user
    lender_admin
    premium_collector_user
  ).each do |user_type|
    context "as a #{user_type.humanize}" do
      let!(:current_user) { FactoryGirl.create(user_type) }

      let!(:cfe_user1) { FactoryGirl.create(:cfe_user) }

      let!(:cfe_user2) { FactoryGirl.create(:cfe_user) }

      it 'should send email to CfE users' do
        navigate_to_contact_support_form
        send_support_request

        ActionMailer::Base.deliveries.size.should == 1
        email = ActionMailer::Base.deliveries.first
        email.to.should == [ cfe_user1.email, cfe_user2.email ]
      end
    end
  end

  %w(
    cfe_admin
    cfe_user
  ).each do |user_type|
    context "as a #{user_type.humanize}" do
      let!(:current_user) { FactoryGirl.create(user_type) }

      let!(:super_user1) { FactoryGirl.create(:super_user) }

      let!(:super_user2) { FactoryGirl.create(:super_user) }

      it 'should send email to super users' do
        navigate_to_contact_support_form
        send_support_request

        ActionMailer::Base.deliveries.size.should == 1
        email = ActionMailer::Base.deliveries.first
        email.to.should == [ super_user1.email, super_user2.email ]
      end
    end
  end

  private

  def navigate_to_contact_support_form
    visit root_path
    click_link 'Contact Support'
  end

  def send_support_request
    fill_in "support_request_message", with: "HELP!!!!"
    click_button "Submit"
    page.should have_content('Your support request has been sent')
  end

end
