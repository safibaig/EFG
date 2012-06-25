require 'spec_helper'

describe 'loan states' do
  describe '#index' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

    before do
      login_as(current_user, scope: :user)
      FactoryGirl.create(:loan, lender: current_lender)
      FactoryGirl.create(:loan, :offered, lender: current_lender)
      FactoryGirl.create(:loan, :guaranteed, lender: current_lender)
    end

    def dispatch
      visit loan_states_path
    end

    let(:states) { page.all('tbody th').map(&:text) }
    let(:counts) { page.all('tbody td').map(&:text) }

    it 'lists loan states and the number of loans' do
      dispatch

      {
        'Rejected' => 0,
        'Eligible' => 1,
        'Cancelled' => 0,
        'Incomplete' => 0,
        'Completed' => 0,
        'Offered' => 1,
        'Guaranteed' => 1
      }.each do |name, count|
        counts[states.index(name)].should == count.to_s
      end
    end

    it 'does not include loans from another lender' do
      FactoryGirl.create(:loan, :completed)
      FactoryGirl.create(:loan, :offered)

      dispatch

      {
        'Rejected' => 0,
        'Eligible' => 1,
        'Cancelled' => 0,
        'Incomplete' => 0,
        'Completed' => 0,
        'Offered' => 1,
        'Guaranteed' => 1
      }.each do |name, count|
        counts[states.index(name)].should == count.to_s
      end
    end
  end

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

      names = page.all('tbody tr td:nth-child(2)').map(&:text)
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
