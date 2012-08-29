require 'spec_helper'

describe 'LoanAllocations' do
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
      current_path.should == lender_loan_allocations_path(lender)
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

      loan_allocation = LoanAllocation.last
      loan_allocation.lender.should == lender
      loan_allocation.modified_by.should == current_user
      loan_allocation.description.should == 'This year'
      loan_allocation.starts_on.should == Date.new(2012, 1, 1)
      loan_allocation.ends_on.should == Date.new(2012, 12, 31)
      loan_allocation.allocation.should == Money.new(5_000_000_00)
      loan_allocation.guarantee_rate.should == 75
      loan_allocation.premium_rate.should == 2
    end
  end

  describe 'update' do
    let!(:loan_allocation) { FactoryGirl.create(:loan_allocation, lender: lender, description: 'Foo', allocation: 1) }

    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link 'Annual'
      click_link 'Foo'
    end

    it do
      page.should_not have_selector('input[name^=loan_allocation_allocation_type_id]')
      page.should_not have_selector('input[name^=loan_allocation_ends_on]')
      page.should_not have_selector('input[name^=loan_allocation_guarantee_rate]')
      page.should_not have_selector('input[name^=loan_allocation_premium_rate]')
      page.should_not have_selector('input[name^=loan_allocation_starts_on]')

      fill_in :description, 'Updated'
      fill_in :allocation, '9999.99'
      click_button 'Update Lender Limit'

      loan_allocation.reload
      loan_allocation.lender.should == lender
      loan_allocation.modified_by.should == current_user
      loan_allocation.description.should == 'Updated'
      loan_allocation.allocation.should == Money.new(9_999_99)
    end
  end

  private
    def choose_radio_button(attribute, value)
      choose "loan_allocation_#{attribute}_#{value}"
    end

    def fill_in(attribute, value)
      page.fill_in "loan_allocation_#{attribute}", with: value
    end
end
