require 'spec_helper'

describe 'phases' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  def dispatch
    visit root_path
    click_link 'Manage Phases'
  end

  describe 'creating a new phase' do
    def dispatch
      super
      visit_new_phase_form
    end

    it 'does not continue with invalid values' do
      dispatch

      click_button 'Create Phase'

      current_path.should == phases_path
    end

    it do
      dispatch

      fill_in 'name', 'Phase 42'

      click_button 'Create Phase'

      phase = Phase.last!
      phase.name.should == 'Phase 42'
      phase.created_by.should == current_user
      phase.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::PhaseCreated
      admin_audit.auditable.should == phase
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'editing a lender' do
    let!(:phase) { FactoryGirl.create(:phase, name: 'Phase 52') }

    def dispatch
      super
      click_link 'Phase 52'
    end

    it 'does not continue with invalid values' do
      dispatch

      fill_in 'name', ''

      click_button 'Update Phase'

      current_path.should == phase_path(phase)
    end

    it do
      dispatch

      fill_in 'name', 'Phase 25'

      click_button 'Update Phase'

      phase.reload
      phase.name.should == 'Phase 25'
      phase.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::PhaseEdited
      admin_audit.auditable.should == phase
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end


  private
    def visit_new_phase_form
      within '.actions' do
        first('a').click
      end
    end

    def fill_in(attribute, value)
      page.fill_in "phase_#{attribute}", with: value
    end

    def choose_radio_button(attribute, value)
      choose "phase_#{attribute}_#{value}"
    end
end
