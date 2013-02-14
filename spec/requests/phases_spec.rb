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
      click_link 'New Phase'
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

  describe 'creating a new phase and setting up lending limits' do
    def dispatch
      super
      click_link 'New Phase with Lending Limits'
    end

    let!(:lender1) { FactoryGirl.create(:lender) }
    let!(:lender2) { FactoryGirl.create(:lender) }
    let!(:lender3) { FactoryGirl.create(:lender) }

    it do
      dispatch

      fill_in 'name', 'Phase'

      choose_radio_button 'allocation_type_id', 1
      fill_in 'lending_limit_name', 'This year'
      fill_in 'starts_on', '1/1/12'
      fill_in 'ends_on', '31/12/12'
      fill_in 'guarantee_rate', '75'
      fill_in 'premium_rate', '2'

      setup_lending_limit lender1, allocation: '987'
      setup_lending_limit lender3, allocation: '123,456.78'

      click_button 'Create Phase'

      phase = Phase.last!
      phase.name.should == 'Phase'
      phase.created_by.should == current_user
      phase.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::PhaseCreated
      admin_audit.auditable.should == phase
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current

      phase.lending_limits.count.should == 2

      phase.lenging_limits.each do |lending_limit|
        lending_limit.name.should == 'This year'
        lending_limit.starts_on.should == Date.new(2012, 1, 1)
        lending_limit.ends_on.should == Date.new(2012, 12, 31)
        lending_limit.guarantee_rate.should == 75
        lending_limit.premium_rate.should == 2
      end

      phase.lending_limits.map(&:lender).should =~ [lender1, lender3]
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
    def fill_in(attribute, value)
      page.fill_in "phase_with_lending_limits_#{attribute}", with: value
    end

    def choose_radio_button(attribute, value)
      choose "phase_with_lending_limits_#{attribute}_#{value}"
    end

    def setup_lending_limit(lender, params = {})
      within "#lender_lending_limit_#{lender.id}" do
        find('input[type=checkbox]').set(true)
        find('input[type=text]').set(params[:allocation])
      end
    end

end
