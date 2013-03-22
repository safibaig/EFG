require 'spec_helper'

describe "bulk creation of lending limits" do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }

  describe 'creating a new phase and setting up lending limits' do
    def dispatch
      visit root_path
      click_link 'Manage Phases'
      visit_bulk_lending_limits_form
    end

    let!(:phase) { FactoryGirl.create(:phase, name: 'Phase 1') }
    let!(:lender1) { FactoryGirl.create(:lender) }
    let!(:lender2) { FactoryGirl.create(:lender) }
    let!(:lender3) { FactoryGirl.create(:lender) }

    it 'does not continue with invalid values' do
      dispatch

      click_button 'Create Lending Limits'

      current_path.should == bulk_lending_limits_path
    end

    it do
      dispatch

      select 'Phase 1', from: 'bulk_lending_limits_scheme_or_phase_id'

      choose_radio_button 'allocation_type_id', 1
      fill_in 'lending_limit_name', 'This year'
      fill_in 'starts_on', '1/1/12'
      fill_in 'ends_on', '31/12/12'
      fill_in 'guarantee_rate', '75'
      fill_in 'premium_rate', '2'

      setup_lending_limit lender1, allocation: '987', active: true
      setup_lending_limit lender3, allocation: '123,456.78', active: false

      click_button 'Create Lending Limits'

      lending_limit_audits = AdminAudit.where(action: AdminAudit::LendingLimitCreated)
      lending_limit_audits.count.should == 2
      lending_limit_audits.map(&:auditable).should =~ LendingLimit.all
      lending_limit_audits.all? {|lending_limit| lending_limit.modified_by == current_user}.should be_true
      lending_limit_audits.all? {|lending_limit| lending_limit.modified_on.should == Date.current }.should be_true

      phase.lending_limits.count.should == 2

      phase.lending_limits.each do |lending_limit|
        lending_limit.name.should == 'This year'
        lending_limit.starts_on.should == Date.new(2012, 1, 1)
        lending_limit.ends_on.should == Date.new(2012, 12, 31)
        lending_limit.guarantee_rate.should == 75
        lending_limit.premium_rate.should == 2
      end

      phase.lending_limits.map(&:lender).should =~ [lender1, lender3]
      phase.lending_limits.map(&:active).should =~ [true, false]
    end
  end

  private
  def visit_bulk_lending_limits_form
    within '.actions' do
      find(:xpath, '//a[contains(.,"Bulk Create Lending Limits")]').click
    end
  end

  def setup_lending_limit(lender, params = {})
    within "#lender_lending_limit_#{lender.id}" do
      find('input[type=checkbox][name*=selected]').set(true)
      find('input[type=text]').set(params.fetch(:allocation))
      find('input[type=checkbox][name*=active]').set(params.fetch(:active))
    end
  end

  def fill_in(attribute, value)
    page.fill_in "bulk_lending_limits_#{attribute}", with: value
  end

  def choose_radio_button(attribute, value)
    choose "bulk_lending_limits_#{attribute}_#{value}"
  end
end
