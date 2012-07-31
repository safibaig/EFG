require 'spec_helper'

describe 'Generate a loan report' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let!(:loan) { FactoryGirl.create(:loan, :eligible, :sflg) }

  let!(:loan) { FactoryGirl.create(:loan, :guaranteed, :sflg) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit new_loan_report_path
  end

  it "should generate CSV report for all loan state and all schemes" do
    click_button "Submit"

    page.should have_content "Data extract found 2 rows"

    click_button "Download Report"

    # check CSV rendered
  end

end
