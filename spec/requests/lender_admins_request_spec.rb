require 'spec_helper'
require 'memorable_password'

describe 'LenderAdmin management' do
  let!(:lender) { FactoryGirl.create(:lender, name: 'Bankers') }
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  describe 'list' do
    before do
      FactoryGirl.create(:lender_admin, first_name: 'Barry', last_name: 'White')
      FactoryGirl.create(:lender_user, first_name: 'David', last_name: 'Bowie')
    end

    it do
      visit root_path
      click_link 'Manage Lender Admins'

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
      click_link 'Manage Lender Admins'

      click_link 'New Lender Admin'

      select 'lender_id', 'Bankers'
      fill_in 'first_name', 'Bob'
      fill_in 'last_name', 'Flemming'
      fill_in 'email', 'bob.flemming@example.com'

      expect {
        click_button 'Create Lender admin'
      }.to change(LenderAdmin, :count).by(1)

      page.should have_content('Bankers')
      page.should have_content('Bob Flemming')
      page.should have_content('bob.flemming@example.com')
      page.should have_content('correct horse battery staple')
    end
  end

  describe 'update' do
    before do
      FactoryGirl.create(:lender_admin, first_name: 'Bob', last_name: 'Flemming', lender: lender)
    end

    it do
      visit root_path
      click_link 'Manage Lender Admins'

      click_link 'Bob Flemming'

      page.should_not have_selector('#lender_admin_lender_id')

      fill_in 'first_name', 'Bill'
      fill_in 'last_name', 'Example'
      fill_in 'email', 'bill.example@example.com'

      click_button 'Update Lender admin'

      page.should have_content('Bankers')
      page.should have_content('Bill Example')
      page.should have_content('bill.example@example.com')
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "lender_admin_#{attribute}", with: value
    end

    def select(attribute, value)
      page.select value, from: "lender_admin_#{attribute}"
    end
end
