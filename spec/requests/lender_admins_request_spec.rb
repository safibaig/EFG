require 'spec_helper'

describe 'LenderAdmin management' do
  let!(:lender) { FactoryGirl.create(:lender, name: 'Bankers') }
  let(:current_user) { FactoryGirl.create(:cfe_admin) }

  before { login_as(current_user, scope: :user) }

  describe 'list' do
    let!(:lender_admin) { FactoryGirl.create(:lender_admin, lender: lender, first_name: 'Barry', last_name: 'White') }
    let!(:lender_user) { FactoryGirl.create(:lender_user,  lender: lender, first_name: 'David', last_name: 'Bowie') }

    context 'as a CfE Admin' do
      let(:current_user) { FactoryGirl.create(:cfe_admin) }

      before do
        visit root_path
        click_link 'Manage Lenders'
        within(:css, "tr#lender_#{lender.id}") do
          click_link 'Lender Admins'
        end
      end

      it 'includes Lender Admins with links to edit' do
        page.should have_content('Bankers')
        page.should have_link(lender_admin.name, href: edit_lender_lender_admin_path(lender, lender_admin))
      end

      it 'does not include Lender Users' do
        page.should_not have_content(lender_user.name)
      end

      it_should_behave_like 'an admin viewing active and disabled users' do
        let!(:active_user) { lender_admin }
        let!(:disabled_user) {
          FactoryGirl.create(:lender_admin,
                             first_name: 'Dave',
                             last_name: 'Smith',
                             disabled: true,
                             lender: lender)
        }
      end
    end

    context 'as a Lender Admin' do
      let(:current_user) { FactoryGirl.create(:lender_admin, lender: lender) }
      let!(:other_lender_admin) { FactoryGirl.create(:lender_admin, first_name: 'Bob', last_name: 'Flemming') }

      before do
        visit root_path
        click_link 'View Lender Admins'
      end

      it 'includes Lender Admins from my Lender' do
        page.should have_content('Bankers')
        page.should have_content(lender_admin.name)
      end

      it 'includes a link to show visible Lender Admin' do
        page.should have_link(lender_admin.name, href: lender_lender_admin_path(lender, lender_admin))
      end

      it 'does not include a link to edit visible Lender Admin' do
        page.should_not have_link(lender_admin.name, href: edit_lender_lender_admin_path(lender, lender_admin))
      end

      it 'does not include Lender Users' do
        page.should_not have_content(lender_user.name)
      end

      it 'does not include Lender Admins from other Lender' do
        page.should_not have_content(other_lender_admin.name)
      end

      it_should_behave_like 'an admin viewing active and disabled users' do
        let!(:active_user) { lender_admin }
        let!(:disabled_user) {
          FactoryGirl.create(:lender_admin,
                             first_name: 'Dave',
                             last_name: 'Smith',
                             disabled: true,
                             lender: active_user.lender)
        }
      end
    end
  end

  describe 'create' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it do
      visit root_path
      click_link 'Manage Lenders'
      within(:css, "tr#lender_#{lender.id}") do
        click_link 'Lender Admins'
      end

      click_link 'New Lender Admin'

      fill_in 'first_name', 'Bob'
      fill_in 'last_name', 'Flemming'
      fill_in 'email', 'bob.flemming@example.com'

      expect {
        click_button 'Create Lender Admin'
      }.to change(LenderAdmin, :count).by(1)

      page.should have_content('Bankers')
      page.should have_content('Bob Flemming')
      page.should have_content('bob.flemming@example.com')

      user = LenderAdmin.last!
      user.lender.should == lender
      user.created_by.should == current_user
      user.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserCreated
      admin_audit.auditable.should == user
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current

      # verify email is sent to user
      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end
  end

  describe 'update' do
    let!(:user) { FactoryGirl.create(:lender_admin, first_name: 'Bob', last_name: 'Flemming', lender: lender) }

    it do
      visit root_path
      click_link 'Manage Lenders'
      within(:css, "tr#lender_#{lender.id}") do
        click_link 'Lender Admins'
      end

      click_link 'Bob Flemming'

      page.should_not have_selector('#lender_admin_lender_id')

      fill_in 'first_name', 'Bill'
      fill_in 'last_name', 'Example'
      fill_in 'email', 'bill.example@example.com'

      click_button 'Update Lender Admin'

      user.reload
      user.email.should == 'bill.example@example.com'
      user.first_name.should == 'Bill'
      user.last_name.should == 'Example'
      user.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserEdited
      admin_audit.auditable.should == user
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'unlocking the user' do
    let!(:lender_admin) {
      FactoryGirl.create(:lender_admin,
                         first_name: 'Bob',
                         last_name: 'Flemming',
                         lender: lender,
                         locked: true)
    }

    before do
      visit root_path
    end

    context 'as a Lender Admin' do
      let(:current_user) { FactoryGirl.create(:lender_admin, lender: lender) }

      it 'unlocks the user' do
        click_link 'View Lender Admins'
        click_link 'Bob Flemming'
        click_button 'Unlock User'

        lender_admin.reload.should_not be_locked
      end
    end

    context 'as a Cfe Admin' do
      it 'unlocks the user' do
        click_link 'Manage Lenders'
        within(:css, "tr#lender_#{lender.id}") do
          click_link 'Lender Admins'
        end
        click_link 'Bob Flemming'
        click_button 'Unlock User'

        lender_admin.reload.should_not be_locked
      end
    end

    after do
      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserUnlocked
      admin_audit.auditable.should == lender_admin
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'disabling the user' do
    let!(:lender_admin) {
      FactoryGirl.create(:lender_admin,
                         first_name: 'Bob',
                         last_name: 'Flemming',
                         lender: lender)
    }

    before do
      visit root_path
    end

    context 'as a Lender Admin' do
      let(:current_user) { FactoryGirl.create(:lender_admin, lender: lender) }

      it 'disables the user' do
        click_link 'View Lender Admins'
        click_link 'Bob Flemming'
        click_button 'Disable User'

        lender_admin.reload.should be_disabled
      end
    end

    context 'as a Cfe Admin' do
      it 'disables the user' do
        click_link 'Manage Lenders'
        within(:css, "tr#lender_#{lender.id}") do
          click_link 'Lender Admins'
        end
        click_link 'Bob Flemming'
        click_button 'Disable User'

        lender_admin.reload.should be_disabled
      end
    end

    after do
      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserDisabled
      admin_audit.auditable.should == lender_admin
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'enabling the user' do
    let!(:lender_admin) {
      FactoryGirl.create(:lender_admin,
                         first_name: 'Bob',
                         last_name: 'Flemming',
                         lender: lender,
                         disabled: true)
    }

    before do
      visit root_path
    end

    context 'as a Lender Admin' do
      let(:current_user) { FactoryGirl.create(:lender_admin, lender: lender) }

      it 'enables the user' do
        click_link 'View Lender Admins'
        click_link 'Disabled'
        click_link 'Bob Flemming'
        click_button 'Enable User'

        lender_admin.reload.should_not be_disabled
      end
    end

    context 'as a CfE Admin' do
      it 'enables the user' do
        click_link 'Manage Lenders'
        within(:css, "tr#lender_#{lender.id}") do
          click_link 'Lender Admins'
        end
        click_link 'Disabled'
        click_link 'Bob Flemming'
        click_button 'Enable User'

        lender_admin.reload.should_not be_disabled
      end
    end

    after do
      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::UserEnabled
      admin_audit.auditable.should == lender_admin
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe "sending reset password email to user without a password" do
    let!(:user) {
      user = FactoryGirl.create(
        :lender_admin,
        first_name: 'Bob',
        last_name: 'Flemming',
        lender: lender,
      )
      user.encrypted_password = nil
      user.save(validate: false)
      user
    }

    before(:each) do
      ActionMailer::Base.deliveries.clear
    end

    it "can be sent from edit user page" do
      user.reset_password_token.should be_nil
      user.reset_password_sent_at.should be_nil

      visit root_path
      click_link 'Manage Lenders'
      within(:css, "tr#lender_#{lender.id}") do
        click_link 'Lender Admins'
      end
      click_link 'Bob Flemming'
      click_button 'Send Reset Password Email'

      page.should have_content(I18n.t('manage_users.reset_password_sent', email: user.email))

      user.reload
      user.reset_password_token.should_not be_nil
      user.reset_password_sent_at.should_not be_nil

      # verify email is sent to user
      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end

    it "can be sent from user list page" do
      visit root_path
      click_link 'Manage Lenders'
      within(:css, "tr#lender_#{lender.id}") do
        click_link 'Lender Admins'
      end
      click_button 'Send Reset Password Email'

      page.should have_content(I18n.t('manage_users.reset_password_sent', email: user.email))
      page.should have_content(I18n.t('manage_users.password_set_time_remaining', time_left: '7 days'))
      page.should_not have_css('input', text: 'Send Reset Password Email')
    end

    # many imported users will not have an email address
    it 'fails when user does not have an email address' do
      user.email = nil
      user.save(validate: false)

      visit root_path
      click_link 'Manage Lenders'
      within(:css, "tr#lender_#{lender.id}") do
        click_link 'Lender Admins'
      end
      click_link 'Bob Flemming'
      click_button 'Send Reset Password Email'

      page.should have_content("can't be blank")
      ActionMailer::Base.deliveries.should be_empty
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
