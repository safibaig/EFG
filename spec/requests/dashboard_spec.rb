# encoding: utf-8

require 'spec_helper'

describe 'lender dashboard' do

  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }

  context "with loan allocations" do

    let(:loan_allocation1) { current_lender.loan_allocations.first }

    let(:loan_allocation2) { FactoryGirl.create(:loan_allocation, lender: current_lender, allocation: 3000000) }

    let!(:loan1) {
      FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: current_lender,
        loan_allocation: loan_allocation1,
        amount: 250000
      )
    }

    let!(:loan2) {
      FactoryGirl.create(
        :loan,
        :guaranteed,
        lender: current_lender,
        loan_allocation: loan_allocation2,
        amount: 800000
      )
    }

    before do
      login_as(current_user, scope: :user)
    end

    it "should display loan allocation summary" do
      visit root_path

      within '#utilisation_dashboard' do
        page.should have_content(loan_allocation1.starts_on.strftime('%B %Y') + ' - ' + loan_allocation1.ends_on.strftime('%B %Y'))
        page.should have_content('Allocation: £1,000,000.00')
        page.should have_content('Usage: £250,000.00')
        page.should have_content('Utilisation: 25.00%')

        page.should have_content(loan_allocation2.starts_on.strftime('%B %Y') + ' - ' + loan_allocation2.ends_on.strftime('%B %Y'))
        page.should have_content('Allocation: £3,000,000.00')
        page.should have_content('Usage: £800,000.00')
        page.should have_content('Utilisation: 26.67%')
      end
    end

  end

  context "with not drawn loan alerts" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 180.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 170.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 130.days.ago) }

    before do
      login_as(current_user, scope: :user)
    end

    it "should display high, medium and low priority loan alerts" do
      visit root_path

      page.should have_css "#not_drawn_loan_alerts a.high-priority .total-loans", text: "1"
      page.should have_css "#not_drawn_loan_alerts a.medium-priority .total-loans", text: "1"
      page.should have_css "#not_drawn_loan_alerts a.low-priority .total-loans", text: "1"
    end

  end

  context "demanded loan alerts" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: current_lender, updated_at: 360.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: current_lender, updated_at: 350.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: current_lender, updated_at: 310.days.ago) }

    before do
      login_as(current_user, scope: :user)
    end

    it "should display high, medium and low priority loan alerts" do
      visit root_path

      page.should have_css "#demanded_loan_alerts a.high-priority .total-loans", text: "1"
      page.should have_css "#demanded_loan_alerts a.medium-priority .total-loans", text: "1"
      page.should have_css "#demanded_loan_alerts a.low-priority .total-loans", text: "1"
    end

  end

  context "not progressed loan alerts" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :eligible, lender: current_lender, updated_at: 180.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :completed, lender: current_lender, updated_at: 170.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :incomplete, lender: current_lender, updated_at: 130.days.ago) }

    before do
      login_as(current_user, scope: :user)
    end

    it "should display high, medium and low priority loan alerts" do
      visit root_path

      page.should have_css "#not_progressed_loan_alerts a.high-priority .total-loans", text: "1"
      page.should have_css "#not_progressed_loan_alerts a.medium-priority .total-loans", text: "1"
      page.should have_css "#not_progressed_loan_alerts a.low-priority .total-loans", text: "1"
    end

  end

  context "assumed repaid loan alerts" do

    let!(:high_priority_incomplete_loan) { FactoryGirl.create(:loan, :incomplete, lender: current_lender, maturity_date: 180.days.ago) }

    let!(:medium_priority_guaranteed_loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender, maturity_date: 70.days.ago) }

    let!(:low_priority_offered_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, maturity_date: 125.days.ago) }

    before do
      login_as(current_user, scope: :user)
    end

    it "should display high, medium and low priority loan alerts" do
      visit root_path

      page.should have_css "#assumed_repaid_loan_alerts a.high-priority .total-loans", text: "1"
      page.should have_css "#assumed_repaid_loan_alerts a.medium-priority .total-loans", text: "1"
      page.should have_css "#assumed_repaid_loan_alerts a.low-priority .total-loans", text: "1"
    end

  end

end
