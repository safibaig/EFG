# encoding: utf-8

require 'spec_helper'

describe 'lender dashboard' do
  shared_examples 'dashboard' do
    context "with not drawn loan alerts" do
      let!(:high_priority_loan) { FactoryGirl.create(:loan, :offered, lender: lender, facility_letter_date: 190.days.ago) }
      let!(:medium_priority_loan) { FactoryGirl.create(:loan, :offered, lender: lender, facility_letter_date: 180.days.ago) }
      let!(:low_priority_loan) { FactoryGirl.create(:loan, :offered, lender: lender, facility_letter_date: 140.days.ago) }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_drawn_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#not_drawn_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_drawn_loan_alerts a.low-priority .total-loans", text: "1"
      end
    end

    context "demanded loan alerts" do
      let!(:high_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: lender, borrower_demanded_on: 360.days.ago) }
      let!(:medium_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: lender, borrower_demanded_on: 350.days.ago) }
      let!(:low_priority_loan) { FactoryGirl.create(:loan, :demanded, lender: lender, borrower_demanded_on: 310.days.ago) }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#demanded_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#demanded_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#demanded_loan_alerts a.low-priority .total-loans", text: "1"
      end
    end

    context "not progressed loan alerts" do
      let!(:high_priority_loan) { FactoryGirl.create(:loan, :eligible, lender: lender, updated_at: 180.days.ago) }
      let!(:medium_priority_loan) { FactoryGirl.create(:loan, :completed, lender: lender, updated_at: 170.days.ago) }
      let!(:low_priority_loan) { FactoryGirl.create(:loan, :incomplete, lender: lender, updated_at: 130.days.ago) }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#not_progressed_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#not_progressed_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#not_progressed_loan_alerts a.low-priority .total-loans", text: "1"
      end
    end

    context "assumed repaid loan alerts" do
      let!(:high_priority_incomplete_loan) { FactoryGirl.create(:loan, :incomplete, lender: lender, maturity_date: 180.days.ago) }
      let!(:medium_priority_guaranteed_loan) { FactoryGirl.create(:loan, :guaranteed, lender: lender, maturity_date: 70.days.ago) }
      let!(:low_priority_offered_loan) { FactoryGirl.create(:loan, :offered, lender: lender, maturity_date: 125.days.ago) }

      it "should display high, medium and low priority loan alerts" do
        visit root_path

        page.should have_css "#assumed_repaid_loan_alerts a.high-priority .total-loans", text: "1"
        page.should have_css "#assumed_repaid_loan_alerts a.medium-priority .total-loans", text: "1"
        page.should have_css "#assumed_repaid_loan_alerts a.low-priority .total-loans", text: "1"
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
