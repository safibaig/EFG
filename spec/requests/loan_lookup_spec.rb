require 'spec_helper'

describe "loan lookup" do

  let(:current_lender) { FactoryGirl.create(:lender) }

  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  let!(:loan) { FactoryGirl.create(:loan, :guaranteed, reference: "9BCI17R-01", lender: current_lender) }

  before do
    login_as(current_user, scope: :user)
  end

  it "should find a loan by partial reference" do
    visit root_path

    lookup_loan("BCI17")

    page.should have_content("Search Results")
    page.should have_content("1 result found")
    page.should have_content(loan.reference)
  end

  it "should cater for no search results" do
    visit root_path

    lookup_loan("wrong")

    page.should have_content("Search Results")
    page.should have_content("0 results found")
  end

  private

  def lookup_loan(reference)
    within "#loan_lookup" do
      fill_in "lookup_term", :with => reference
      click_button "submit_lookup"
    end
  end

end
