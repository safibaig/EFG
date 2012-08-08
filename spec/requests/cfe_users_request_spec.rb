require 'spec_helper'
require 'memorable_password'

describe 'CfeUser management' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  describe 'list' do
    before do
      FactoryGirl.create(:cfe_user, first_name: 'Barry', last_name: 'White')
      FactoryGirl.create(:lender_user, first_name: 'David', last_name: 'Bowie')
    end

    it do
      visit root_path
      click_link 'Manage CfE Users'

      page.should have_content('Barry White')
      page.should_not have_content('David Bowie')
    end
  end

  describe 'create' do
    before do
      MemorablePassword.stub!(:generate).and_return('correct horse battery staple')
    end

    it do
      visit root_path
      click_link 'Manage CfE Users'

      click_link 'New CfE User'

      fill_in 'first_name', 'Bob'
      fill_in 'last_name', 'Flemming'
      fill_in 'email', 'bob.flemming@example.com'

      expect {
        click_button 'Create CfE User'
      }.to change(CfeUser, :count).by(1)

      page.should have_content('Bob Flemming')
      page.should have_content('bob.flemming@example.com')
      page.should have_content('correct horse battery staple')
    end
  end

  describe 'update' do
    before do
      FactoryGirl.create(:cfe_user, first_name: 'Bob', last_name: 'Flemming')
    end

    it do
      visit root_path
      click_link 'Manage CfE Users'

      click_link 'Bob Flemming'

      fill_in 'first_name', 'Bill'
      fill_in 'last_name', 'Example'
      fill_in 'email', 'bill.example@example.com'

      click_button 'Update CfE User'

      page.should have_content('Bill Example')
      page.should have_content('bill.example@example.com')
    end
  end

  describe 'unlocking the user' do
    let!(:user) { FactoryGirl.create(:cfe_user, first_name: 'Bob', last_name: 'Flemming', locked: true) }

    it do
      visit root_path
      click_link 'Manage CfE Users'
      click_link 'Bob Flemming'

      uncheck 'Locked'
      click_button 'Update CfE User'

      user.reload.locked.should == false
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "cfe_user_#{attribute}", with: value
    end

    def select(attribute, value)
      page.select value, from: "cfe_user_#{attribute}"
    end
end
