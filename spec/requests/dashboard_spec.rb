# encoding: utf-8

require 'spec_helper'

describe 'lender dashboard' do
  shared_examples 'dashboard' do
    context "with not drawn loan alerts" do
      let(:start_date) { (6.months.ago - 10.days).to_date }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: start_date
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 11.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 30.weekdays_from(start_date)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          facility_letter_date: 60.weekdays_from(start_date)
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_drawn_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#not_drawn_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_drawn_loan_alerts a.low-priority .total-loans", text: "1"

        find("#not_drawn_loan_alerts a.high-priority").click
        page.should have_content(high_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_drawn_loan_alerts a.medium-priority").click
        page.should have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_drawn_loan_alerts a.low-priority").click
        page.should have_content(low_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
      end
    end

    context "not demanded loan alerts" do
      let(:start_date) { 365.days.ago.to_date }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: start_date
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :legacy_sflg,
          lender: lender,
          borrower_demanded_on: 11.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: 30.weekdays_from(start_date)
        )
      }

      # EFG loans are excluded from this loan alert
      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          lender: lender,
          borrower_demanded_on: start_date
        )
      }

      let!(:loan_not_in_alerts2) {
        FactoryGirl.create(
          :loan,
          :lender_demand,
          :sflg,
          lender: lender,
          borrower_demanded_on: start_date - 1.day
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_demanded_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#not_demanded_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_demanded_loan_alerts a.low-priority .total-loans", text: "1"

        find("#not_demanded_loan_alerts a.high-priority").click
        page.should have_content(high_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
        page.should_not have_content(loan_not_in_alerts2.reference)

        visit root_path

        find("#not_demanded_loan_alerts a.medium-priority").click
        page.should have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
        page.should_not have_content(loan_not_in_alerts2.reference)

        visit root_path

        find("#not_demanded_loan_alerts a.low-priority").click
        page.should have_content(low_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
        page.should_not have_content(loan_not_in_alerts2.reference)
      end
    end

    context "not progressed loan alerts" do
      let(:start_date) { 6.months.ago.to_date }

      let!(:high_priority_loan) {
        FactoryGirl.create(
          :loan,
          :eligible,
          lender: lender,
          updated_at: start_date
        )
      }

      let!(:medium_priority_loan) {
        FactoryGirl.create(
          :loan,
          :completed,
          lender: lender,
          updated_at: 11.weekdays_from(start_date)
        )
      }

      let!(:low_priority_loan) {
        FactoryGirl.create(
          :loan,
          :incomplete,
          lender: lender,
          updated_at: 30.weekdays_from(start_date)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :incomplete,
          lender: lender,
          updated_at: 60.weekdays_from(start_date)
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_progressed_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#not_progressed_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_progressed_loan_alerts a.low-priority .total-loans", text: "1"

        find("#not_progressed_loan_alerts a.high-priority").click
        page.should have_content(high_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_progressed_loan_alerts a.medium-priority").click
        page.should have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(low_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_progressed_loan_alerts a.low-priority").click
        page.should have_content(low_priority_loan.reference)
        page.should_not have_content(medium_priority_loan.reference)
        page.should_not have_content(high_priority_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
      end
    end

    context "not closed loan alerts" do
      let!(:high_priority_incomplete_loan) {
        FactoryGirl.create(
          :loan,
          :incomplete,
          lender: lender,
          maturity_date: 6.months.ago
        )
      }

      let!(:high_priority_guaranteed_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          lender: lender,
          maturity_date: 92.days.ago
        )
      }

      let!(:medium_priority_complete_loan) {
        FactoryGirl.create(
          :loan,
          :completed,
          lender: lender,
          maturity_date: 11.weekdays_from(6.months.ago)
        )
      }

      let!(:low_priority_offered_loan) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          maturity_date: 30.weekdays_from(6.months.ago)
        )
      }

      let!(:low_priority_legacy_loan) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          :legacy_sflg,
          lender: lender,
          maturity_date: 30.weekdays_from(6.months.ago)
        )
      }

      let!(:loan_not_in_alerts) {
        FactoryGirl.create(
          :loan,
          :offered,
          lender: lender,
          maturity_date: 60.weekdays_from(6.months.ago)
        )
      }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_closed_loan_alerts a.high-priority .total-loans", text: "2"
        page.should have_css "#not_closed_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_closed_loan_alerts a.low-priority .total-loans", text: "2"

        find("#not_closed_loan_alerts a.high-priority").click
        page.should have_content(high_priority_incomplete_loan.reference)
        page.should have_content(high_priority_guaranteed_loan.reference)
        page.should_not have_content(medium_priority_complete_loan.reference)
        page.should_not have_content(low_priority_offered_loan.reference)
        page.should_not have_content(low_priority_legacy_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_closed_loan_alerts a.medium-priority").click
        page.should have_content(medium_priority_complete_loan.reference)
        page.should_not have_content(high_priority_incomplete_loan.reference)
        page.should_not have_content(high_priority_guaranteed_loan.reference)
        page.should_not have_content(low_priority_offered_loan.reference)
        page.should_not have_content(low_priority_legacy_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)

        visit root_path

        find("#not_closed_loan_alerts a.low-priority").click
        page.should have_content(low_priority_offered_loan.reference)
        page.should have_content(low_priority_legacy_loan.reference)
        page.should_not have_content(high_priority_incomplete_loan.reference)
        page.should_not have_content(high_priority_guaranteed_loan.reference)
        page.should_not have_content(medium_priority_complete_loan.reference)
        page.should_not have_content(loan_not_in_alerts.reference)
      end
    end
  end

  context 'user logging in for the first time' do
    let(:user) { FactoryGirl.create(:cfe_user) }

    before { login_as(user, scope: :user) }

    it 'should show correct welcome message' do
      visit root_path
      page.should have_content "Welcome #{user.first_name}"
    end
  end

  context 'user logging in for the second time' do
    let(:user) { FactoryGirl.create(:cfe_user, sign_in_count: 2) }

    before { login_as(user, scope: :user) }

    it 'should show correct welcome message' do
      visit root_path
      page.should have_content "Welcome back, #{user.first_name}"
    end
  end

  context 'CfeUser' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:user) { FactoryGirl.create(:cfe_user) }

    before { login_as(user, scope: :user) }

    it_behaves_like 'dashboard'
  end

  context 'LenderUser' do
    let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }
    let(:user) { FactoryGirl.create(:lender_user, lender: lender) }

    before { login_as(user, scope: :user) }

    it_behaves_like 'dashboard'

    context "with LendingLimits" do
      let(:lending_limit1) { lender.lending_limits.first }
      let(:lending_limit2) { FactoryGirl.create(:lending_limit, lender: lender, allocation: 3000000) }

      let!(:loan1) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          lender: lender,
          lending_limit: lending_limit1,
          amount: 250000
        )
      }

      let!(:loan2) {
        FactoryGirl.create(
          :loan,
          :guaranteed,
          lender: lender,
          lending_limit: lending_limit2,
          amount: 800000
        )
      }

      it "should display LendingLimit summary" do
        visit root_path

        within '#utilisation_dashboard' do
          page.should have_content(lending_limit1.name)
          page.should have_content('Allocation: £1,000,000.00')
          page.should have_content('Usage: £250,000.00')
          page.should have_content('Utilisation: 25.00%')

          page.should have_content(lending_limit2.name)
          page.should have_content('Allocation: £3,000,000.00')
          page.should have_content('Usage: £800,000.00')
          page.should have_content('Utilisation: 26.67%')
        end
      end
    end
  end
end
