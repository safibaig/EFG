require 'spec_helper'

describe 'User creation and first login' do

  let!(:cfe_admin) { FactoryGirl.create(:cfe_admin) }

  let!(:lender) { FactoryGirl.create(:lender, name: 'Bankers') }

  before { login_as(cfe_admin, scope: :user) }

  it do
    # cfe admin creates new lender admin
    visit root_path
    click_link 'Manage Lenders'
    within(:css, "tr#lender_#{lender.id}") do
      click_link 'Lender Admins'
    end
    click_link 'New Lender Admin'

    fill_in 'lender_admin_first_name', with: 'Bob'
    fill_in 'lender_admin_last_name', with: 'Flemming'
    fill_in 'lender_admin_email', with: 'bob.flemming@example.com'
    click_button 'Create Lender Admin'

    lender_admin = LenderAdmin.last!

    admin_audit = AdminAudit.last!
    admin_audit.action.should == AdminAudit::UserCreated
    admin_audit.auditable.should == lender_admin
    admin_audit.modified_by.should == cfe_admin
    admin_audit.modified_on.should == Date.current

    click_link "Logout"

    # try to login as new lender admin before password is set
    visit root_path
    fill_in 'user_username', with: lender_admin.username
    click_button 'Sign In'

    page.should have_content('Invalid username or password')

    fill_in 'user_username', with: lender_admin.username
    fill_in 'user_password', with: 'whatever'
    click_button 'Sign In'

    page.should have_content('Invalid username or password')

    # newly created lender admin sets password
    visit edit_user_password_path(reset_password_token: lender_admin.reset_password_token)

    # check validation
    click_button 'Change Password'
    page.should have_content("can't be blank")

    fill_in 'user[password]', with: 'new-password'
    click_button 'Change Password'
    page.should have_content("doesn't match confirmation")

    fill_in 'user[password]', with: 'new-password'
    fill_in 'user[password_confirmation]', with: 'wrong'
    click_button 'Change Password'
    page.should have_content("doesn't match confirmation")

    # valid new password
    new_password = 'new-password-W1bbL3'
    fill_in 'user[password]', with: new_password
    fill_in 'user[password_confirmation]', with: new_password
    click_button 'Change Password'

    page.should have_content('Your password was set successfully. You are now signed in.')

    admin_audit = AdminAudit.last!
    admin_audit.action.should == AdminAudit::UserInitialLogin
    admin_audit.auditable.should == lender_admin
    admin_audit.modified_by.should == lender_admin
    admin_audit.modified_on.should == Date.current

    # user logs out and logs in again with new password
    click_link "Logout"

    fill_in 'user_username', with: lender_admin.username
    fill_in 'user_password', with: new_password
    click_button 'Sign In'

    page.should have_content('Signed in successfully')
  end

end
