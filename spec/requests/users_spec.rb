require 'spec_helper'

describe "user management" do
  before do
    user = FactoryGirl.create(:user)
    login_as(user, scope: :user)
  end

  it "should show a list of all users" do
    FactoryGirl.create(:user, name: 'Florine Flatley', email: 'flatley_florine@example.com')
    FactoryGirl.create(:user, name: 'Roselyn Morissette', email: 'morissette.roselyn@example.com')

    visit root_path
    click_link 'User Management'

    page.should have_content('Florine Flatley')
    page.should have_content('flatley_florine@example.com')
    page.should have_content('Roselyn Morissette')
    page.should have_content('morissette.roselyn@example.com')
  end
end
