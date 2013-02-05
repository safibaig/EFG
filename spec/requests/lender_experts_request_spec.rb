require 'spec_helper'

describe 'lenders' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  describe 'listing' do
    let(:lender1) { FactoryGirl.create(:lender) }
    let!(:expert_user1) { FactoryGirl.create(:expert_lender_user, lender: lender1) }

    let(:lender2) { FactoryGirl.create(:lender) }
    let!(:expert_user2) { FactoryGirl.create(:expert_lender_user, lender: lender2) }

    it "lists a lender's expert users" do
      visit root_path
      click_link 'Manage Lenders'

      within_lender(lender1) do
        click_link 'Expert Users'
      end

      page.should have_content(expert_user1.name)
      page.should_not have_content(expert_user2.name)
    end
  end

  def within_lender(lender, &block)
    within("#lender_#{lender.id}", &block)
  end
end
