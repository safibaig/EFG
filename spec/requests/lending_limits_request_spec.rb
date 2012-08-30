require 'spec_helper'

describe 'LendingLimits' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }
  let!(:lender) { FactoryGirl.create(:lender, name: 'ACME') }

  describe 'create' do
    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link 'Annual'
      click_link 'New Lender Limit'
    end

    it 'does not continue with invalid values' do
      click_button 'Create Lender Limit'
      current_path.should == lender_lending_limits_path(lender)
    end

    it do
      choose_radio_button :allocation_type_id, 1
      fill_in :description, 'This year'
      fill_in :starts_on, '1/1/12'
      fill_in :ends_on, '31/12/12'
      fill_in :allocation, '5000000'
      fill_in :guarantee_rate, '75'
      fill_in :premium_rate, '2'
      click_button 'Create Lender Limit'

      lending_limit = LendingLimit.last
      lending_limit.lender.should == lender
      lending_limit.modified_by.should == current_user
      lending_limit.description.should == 'This year'
      lending_limit.starts_on.should == Date.new(2012, 1, 1)
      lending_limit.ends_on.should == Date.new(2012, 12, 31)
      lending_limit.allocation.should == Money.new(5_000_000_00)
      lending_limit.guarantee_rate.should == 75
      lending_limit.premium_rate.should == 2
    end
  end

  describe 'update' do
    let!(:lending_limit) { FactoryGirl.create(:lending_limit, lender: lender, description: 'Foo', allocation: 1) }

    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link 'Annual'
      click_link 'Foo'
    end

    it do
      page.should_not have_selector('input[id^=lending_limit_allocation_type_id]')
      page.should_not have_selector('#lending_limit_ends_on')
      page.should_not have_selector('#lending_limit_guarantee_rate')
      page.should_not have_selector('#lending_limit_premium_rate')
      page.should_not have_selector('#lending_limit_starts_on')

      fill_in :description, 'Updated'
      fill_in :allocation, '9999.99'
      click_button 'Update Lender Limit'

      lending_limit.reload
      lending_limit.lender.should == lender
      lending_limit.modified_by.should == current_user
      lending_limit.description.should == 'Updated'
      lending_limit.allocation.should == Money.new(9_999_99)
    end
  end

  private
    def choose_radio_button(attribute, value)
      choose "lending_limit_#{attribute}_#{value}"
    end

    def fill_in(attribute, value)
      page.fill_in "lending_limit_#{attribute}", with: value
    end
end
