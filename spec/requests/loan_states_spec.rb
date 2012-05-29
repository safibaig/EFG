require 'spec_helper'

describe 'loan states' do
  describe '#show' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

    before do
      login_as(current_user, scope: :user)
      FactoryGirl.create(:loan, :completed, lender: current_lender, business_name: 'ACME')
      FactoryGirl.create(:loan, :completed, lender: current_lender, business_name: 'Foo')
    end

    def dispatch(params)
      visit loan_state_path(params)
    end

    it 'includes loans in the specified state' do
      dispatch(id: 'completed')

      names = page.all('tbody tr td:first-child').map(&:text)
      names.should == %w(ACME Foo)
    end

    it 'includes loans in the specified state' do
      FactoryGirl.create(:loan, :offered, lender: current_lender, business_name: 'Bar')

      dispatch(id: 'completed')

      names = page.all('tbody tr td:first-child').map(&:text)
      names.should_not include('Bar')
    end

    it 'does not include loans from another lender' do
      FactoryGirl.create(:loan, :completed, business_name: 'Baz')

      dispatch(id: 'completed')

      names = page.all('tbody tr td:first-child').map(&:text)
      names.should_not include('Baz')
    end
  end
end
