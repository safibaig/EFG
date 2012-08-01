require 'spec_helper'

describe 'Generate a loan report' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let!(:loan1) { FactoryGirl.create(:loan, :eligible, lender: current_user.lender) }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit new_loan_report_path
  end

  it "should generate CSV report for all loan states and all schemes" do
    click_button "Submit"

    page.should have_content "Data extract found 2 rows"

    click_button "Download Report"

    # verify CSV is rendered
    page.body.should include(LoanCsvExport.new([loan1, loan2]).generate)
  end

  it "should render errors when invalid data is entered in the form" do
    fill_in 'loan_report_facility_letter_start_date', with: 'wrong'
    click_button "Submit"

    page.should have_content I18n.t('simple_form.labels.loan_report.facility_letter_start_date')
    page.should have_content "is invalid"
  end

end
