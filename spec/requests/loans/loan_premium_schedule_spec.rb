# encoding: utf-8
require 'spec_helper'

shared_examples_for 'a premium schedule viewer' do
  let(:lender) { FactoryGirl.create(:lender) }

  let(:loan) {
    FactoryGirl.create(:loan, :completed,
      lender: lender,
      amount: Money.new(100_000_00)
    )
  }

  let!(:premium_schedule) {
    FactoryGirl.create(premium_schedule_type,
      loan: loan,
      initial_draw_amount: Money.new(100_000_00),
      repayment_duration: 120
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

describe 'loan entry' do
  context 'as a lender user' do
    it_should_behave_like 'a premium schedule viewer' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: lender) }
    end
  end

  context 'as a CfE user' do
    it_should_behave_like 'a premium schedule viewer' do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
    end
  end

  context 'when the loan does not have a repayment frequency' do
    let(:current_user) { FactoryGirl.create(:lender_user, lender: lender) }
    let(:lender) { FactoryGirl.create(:lender) }
    let(:loan) {
      FactoryGirl.create(:loan, :completed,
        lender: lender,
        repayment_frequency_id: nil,
        state: 'incomplete'
      )
    }

    before do
      login_as(current_user, scope: :user)
      visit edit_loan_premium_schedule_path(loan)
    end

    it 'should redirect to loan entry' do
      current_path.should == new_loan_entry_path(loan)
    end

    it 'should display the correct flash message' do
      page.should have_content(I18n.t('premium_schedule.repayment_frequency_not_set'))
    end
  end
end
