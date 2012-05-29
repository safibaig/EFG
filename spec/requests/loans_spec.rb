require 'spec_helper'

describe 'loans' do
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
      visit loans_path
    end

    it 'lists loan states and the number of loans' do
      dispatch

      states = page.all('tbody th').map(&:text)
      counts = page.all('tbody td').map(&:text)

      states.should == %w(eligible completed offered guaranteed)
      counts.should == %w(1 0 1 1)
    end

    it 'does not include loans from another lender' do
      FactoryGirl.create(:loan, :completed)
      FactoryGirl.create(:loan, :offered)

      dispatch

      states = page.all('tbody th').map(&:text)
      counts = page.all('tbody td').map(&:text)

      states.should == %w(eligible completed offered guaranteed)
      counts.should == %w(1 0 1 1)
    end
  end
end
