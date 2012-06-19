# encoding: utf-8

require 'spec_helper'

describe 'lender dashboard' do

  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  context "with loan allocations" do

    let(:loan_allocation1) { current_lender.loan_allocations.first }

    let(:loan_allocation2) { FactoryGirl.create(:loan_allocation, lender: current_lender, allocation: 3000000) }

    let!(:loan1) {
      FactoryGirl.create(
        :loan,
        :offered,
        lender: current_lender,
        loan_allocation: loan_allocation1,
        amount: 250000
      )
    }

    let!(:loan2) {
      FactoryGirl.create(
        :loan,
        :offered,
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

  it "should display loan alerts" do
    pending
  end

end
