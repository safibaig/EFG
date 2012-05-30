# encoding: utf-8

require 'spec_helper'
require 'memorable_password'

describe "user management" do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  before do
    login_as(current_user, scope: :user)
  end

  it "should show a list of lender users" do
    other_lender = FactoryGirl.create(:lender)

    FactoryGirl.create(:user,
      lender: current_lender,
      name: 'Florine Flatley',
      email: 'flatley_florine@example.com'
    )
    FactoryGirl.create(:user,
      lender: current_lender,
      name: 'Roselyn Morissette',
      email: 'morissette.roselyn@example.com'
    )
    FactoryGirl.create(:user,
      lender: other_lender,
      name: 'Bob Flemming',
      email: 'bob.flemming@example.com'
    )

    visit root_path
    click_link 'User Management'

    page.should have_content('Florine Flatley')
    page.should have_content('flatley_florine@example.com')
    page.should have_content('Roselyn Morissette')
    page.should have_content('morissette.roselyn@example.com')
    page.should_not have_content('Bob Flemming')
    page.should_not have_content('bob.flemming@example.com')
  end

  it "creating a new user" do
    MemorablePassword.stub!(:generate).and_return('correct horse battery staple')

    visit root_path
    click_link 'User Management'

    click_link 'New User'

    fill_in 'Name', with: 'Aniya Kshlerin'
    fill_in 'Email', with: 'kshlerin.aniya@example.com'

    click_button 'Create User'

    page.should have_content('Aniya Kshlerin')
    page.should have_content('kshlerin.aniya@example.com')
    page.should have_content('correct horse battery staple')
  end

  it "editing a user" do
    FactoryGirl.create(:user,
      lender: current_lender,
      name: 'Jarred Paucek',
      email: 'jarred_paucek@example.com'
    )

    visit root_path
    click_link 'User Management'

    click_link 'Jarred Paucek'

    fill_in 'Name', with: 'Jarred Paucék'
    click_button 'Update User'

    page.should have_content('Jarred Paucék')
  end
end