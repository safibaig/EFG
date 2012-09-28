require 'spec_helper'

describe 'expert users' do
  let(:current_user) { FactoryGirl.create(:lender_admin) }
  let(:lender) { current_user.lender }
  before { login_as(current_user, scope: :user) }

  describe 'listing' do
    let!(:expert_user1) { FactoryGirl.create(:expert_lender_user, lender: lender) }
    let!(:expert_user2) { FactoryGirl.create(:expert_lender_user) }

    it do
      visit root_path
      click_link 'Manage Experts'

      page.should have_content(expert_user1.name)
      page.should_not have_content(expert_user2.name)
    end
  end

  describe 'creating' do
    let!(:lender_user1) { FactoryGirl.create(:lender_user, lender: lender) }
    let!(:lender_user2) { FactoryGirl.create(:lender_user, lender: lender, first_name: 'Ted', last_name: 'Super') }

    it do
      visit root_path
      click_link 'Manage Experts'

      select 'Ted Super', from: 'expert[user_id]'
      click_button 'Add Expert'

      expert = Expert.last!
      expert.lender.should == lender
      expert.user.should == lender_user2

      lender_user2.should be_expert

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderExpertAdded
      admin_audit.auditable.should == lender_user2
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'deleting' do
    let!(:expert_user) { FactoryGirl.create(:expert_lender_user, lender: lender) }

    it do
      visit root_path
      click_link 'Manage Experts'
      click_button 'Remove'

      lender.experts.count.should == 0
      expert_user.should_not be_expert

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderExpertRemoved
      admin_audit.auditable.should == expert_user
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end
end
