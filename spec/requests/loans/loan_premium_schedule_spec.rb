# encoding: utf-8
require 'spec_helper'

describe 'loan entry' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it "viewing a premium schedule" do
    FactoryGirl.create(:state_aid_calculation, loan: loan, initial_draw_amount: Money.new(100_000_00), initial_draw_months: 120)

    visit loan_path(loan)
    click_link 'Generate Premium Schedule'

    page.should have_content('£10,250.00')
  end
end
