# encoding: utf-8
require 'spec_helper'

describe 'loan entry' do
  let(:current_lender) { FactoryGirl.create(:lender) }

  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }

  let(:loan) {
    FactoryGirl.create(:loan, :completed,
      lender: current_lender,
      amount: Money.new(100_000_00)
    )
  }

  let!(:premium_schedule) {
    FactoryGirl.create(premium_schedule_type,
      loan: loan,
      initial_draw_amount: Money.new(100_000_00),
      initial_draw_months: 120
    )
  }

  before do
    login_as(current_user, scope: :user)
    visit loan_path(loan)
    click_link 'Generate Premium Schedule'
  end

  context 'when viewing a premium schedule' do
    let(:premium_schedule_type) { :premium_schedule }

    it 'displays the correct data' do
      page.should have_content('£10,250.00')
      page.should_not have_css('.premium1')
      page.should have_css('.premium2')
      page.should have_css('.premium40')
    end
  end

  context 'when viewing a rescheduled premium schedule' do
    let(:premium_schedule_type) { :rescheduled_premium_schedule }

    it 'displays the correct data' do
      page.should have_css('.premium1')
      page.should have_css('.premium40')
    end
  end
end
