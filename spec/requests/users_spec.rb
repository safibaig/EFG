# encoding: utf-8

require 'spec_helper'
require 'memorable_password'

describe "user management" do
  shared_examples 'creating a user' do
    it "creating a new user" do
      MemorablePassword.stub!(:generate).and_return('correct horse battery staple')

      visit root_path
      click_link 'Manage Users'

      click_link 'New User'

      fill_in 'First name', with: 'Aniya'
      fill_in 'Last name', with: 'Kshlerin'
      fill_in 'Email', with: 'kshlerin.aniya@example.com'

      click_button 'Create User'

      last_user = User.last
      last_user.should be_a(user_klass)

      page.should have_content('Aniya Kshlerin')
      page.should have_content('kshlerin.aniya@example.com')
      page.should have_content('correct horse battery staple')
    end
  end

  context 'CfeUser' do
    let(:user_klass) { CfeUser }
    let(:current_user) { FactoryGirl.create(:cfe_user) }

    before do
      login_as(current_user, scope: :user)
    end

    it_behaves_like 'creating a user'

    it "lists CfE users" do
      FactoryGirl.create(:cfe_user,
        first_name: 'Florine',
        last_name: 'Flatley',
        email: 'flatley_florine@example.com'
      )
      FactoryGirl.create(:lender_user,
        first_name: 'Roselyn',
        last_name: 'Morissette',
        email: 'morissette.roselyn@example.com'
      )

      visit root_path
      click_link 'Manage Users'

      page.should have_content('Florine Flatley')
      page.should have_content('flatley_florine@example.com')
      page.should_not have_content('Roselyn Morissette')
      page.should_not have_content('morissette.roselyn@example.com')
    end

    it "editing a user" do
      FactoryGirl.create(:cfe_user,
        first_name: 'Jarred',
        last_name: 'Paucek',
        email: 'jarred_paucek@example.com'
      )

      visit root_path
      click_link 'Manage Users'

      click_link 'Jarred Paucek'

      fill_in 'First name', with: 'Jarred'
      fill_in 'Last name', with: 'Paucék'
      click_button 'Update User'

      page.should have_content('Jarred Paucék')
    end
  end

  context 'LenderUser' do
    let(:user_klass) { LenderUser }
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }

    before { login_as(current_user, scope: :user) }

    it_behaves_like 'creating a user'

    it "should show a list of the current lender's users" do
      other_lender = FactoryGirl.create(:lender)

      FactoryGirl.create(:lender_user,
        lender: current_lender,
        first_name: 'Florine',
        last_name: 'Flatley',
        email: 'flatley_florine@example.com'
      )
      FactoryGirl.create(:lender_user,
        lender: current_lender,
        first_name: 'Roselyn',
        last_name: 'Morissette',
        email: 'morissette.roselyn@example.com'
      )
      FactoryGirl.create(:lender_user,
        lender: other_lender,
        first_name: 'Bob',
        last_name: 'Flemming',
        email: 'bob.flemming@example.com'
      )

      visit root_path
      click_link 'Manage Users'

      page.should have_content('Florine Flatley')
      page.should have_content('flatley_florine@example.com')
      page.should have_content('Roselyn Morissette')
      page.should have_content('morissette.roselyn@example.com')
      page.should_not have_content('Bob Flemming')
      page.should_not have_content('bob.flemming@example.com')
    end

    it "editing a user" do
      FactoryGirl.create(:lender_user,
        lender: current_lender,
        first_name: 'Jarred',
        last_name: 'Paucek',
        email: 'jarred_paucek@example.com'
      )

      visit root_path
      click_link 'Manage Users'

      click_link 'Jarred Paucek'

      fill_in 'First name', with: 'Jarred'
      fill_in 'Last name', with: 'Paucék'
      click_button 'Update User'

      page.should have_content('Jarred Paucék')
    end
  end
end
