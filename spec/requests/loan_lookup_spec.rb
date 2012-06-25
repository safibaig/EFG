require 'spec_helper'

describe "loan lookup" do

  let(:current_lender) { FactoryGirl.create(:lender) }

  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  let!(:loan1) { FactoryGirl.create(:loan, :guaranteed, reference: "9BCI17R-01", lender: current_lender) }
  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed, reference: "9BCI17R-02", lender: current_lender) }

  before do
    login_as(current_user, scope: :user)
  end

  it "should render results list when multiple loans are found" do
    visit root_path

    lookup_loan(loan1.reference[1,5])

    page.should have_content("Search Results")
    page.should have_content("2 results found")
    page.should have_content(loan1.reference)
    page.should have_content(loan2.reference)
  end

  it "should redirect to loan detail page when a single loan is found" do
    visit root_path

    lookup_loan(loan1.reference)

    page.should have_content("Loan Summary for #{loan1.reference}")
    page.should have_css("#lookup_term[value='#{loan1.reference}']")
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
