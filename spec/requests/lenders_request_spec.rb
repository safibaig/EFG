require 'spec_helper'

describe 'lenders' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  def dispatch
    visit root_path
    click_link 'Manage Lenders'
  end

  describe 'creating a new lender' do
    def dispatch
      super
      click_link 'New Lender'
    end

    it 'does not continue with invalid values' do
      dispatch

      click_button 'Create Lender'

      current_path.should == lenders_path
    end

    it do
      dispatch

      fill_in 'name', 'Bankers'
      select 'loan_scheme', 'EFG only'
      fill_in 'organisation_reference_code', 'BK'
      fill_in 'primary_contact_name', 'Bob Flemming'
      fill_in 'primary_contact_phone', '0123456789'
      fill_in 'primary_contact_email', 'bob@example.com'

      click_button 'Create Lender'

      lender = Lender.last!
      lender.created_by.should == current_user
      lender.modified_by.should == current_user
      lender.name.should == 'Bankers'
      lender.organisation_reference_code.should == 'BK'
      lender.loan_scheme.should == 'E'
      lender.primary_contact_name.should == 'Bob Flemming'
      lender.primary_contact_phone.should == '0123456789'
      lender.primary_contact_email.should == 'bob@example.com'
      lender.can_use_add_cap.should == false

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderCreated
      admin_audit.auditable.should == lender
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'editing a lender' do
    let!(:lender) { FactoryGirl.create(:lender, name: 'ACME') }

    def dispatch
      super
      click_link 'ACME'
    end

    it 'does not continue with invalid values' do
      dispatch

      fill_in 'name', ''

      click_button 'Update Lender'

      current_path.should == lender_path(lender)
    end

    it do
      dispatch

      fill_in 'name', 'Blankers'
      fill_in 'organisation_reference_code', 'BLK'
      fill_in 'primary_contact_name', 'Flob Bemming'
      fill_in 'primary_contact_phone', '987654321'
      fill_in 'primary_contact_email', 'flob@example.com'
      check 'can_use_add_cap'

      click_button 'Update Lender'

      lender.reload
      lender.modified_by.should == current_user
      lender.name.should == 'Blankers'
      lender.organisation_reference_code.should == 'BLK'
      lender.primary_contact_name.should == 'Flob Bemming'
      lender.primary_contact_phone.should == '987654321'
      lender.primary_contact_email.should == 'flob@example.com'
      lender.can_use_add_cap.should == true

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderEdited
      admin_audit.auditable.should == lender
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'activating a lender' do
    let(:lender) { FactoryGirl.create(:lender, disabled: true) }

    def dispatch
      visit edit_lender_path(lender)
    end

    it do
      dispatch
      click_button 'Activate Lender'
      lender.reload
      lender.disabled.should == false
      lender.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderEnabled
      admin_audit.auditable.should == lender
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'deactivating a lender' do
    let(:lender) { FactoryGirl.create(:lender) }

    def dispatch
      visit edit_lender_path(lender)
    end

    it do
      dispatch
      click_button 'Deactivate Lender'
      lender.reload
      lender.disabled.should == true
      lender.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LenderDisabled
      admin_audit.auditable.should == lender
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  private
    def check(attribute)
      page.check "lender_#{attribute}"
    end

    def fill_in(attribute, value)
      page.fill_in "lender_#{attribute}", with: value
    end

    def select(attribute, value)
      page.select value, from: "lender_#{attribute}"
    end
end
