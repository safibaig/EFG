require 'spec_helper'

describe 'Loan audit report' do

  let!(:loan1) { FactoryGirl.create(:loan, :eligible) }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }

  let!(:loan_state_change1) { FactoryGirl.create(:accepted_loan_state_change, loan: loan1) }

  let!(:loan_state_change2) { FactoryGirl.create(:guaranteed_loan_state_change, loan: loan2) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  context "as an auditor" do

    let!(:current_user) { FactoryGirl.create(:auditor_user) }

    it "should output a CSV report for a selection of lenders" do
      navigate_to_loan_audit_report_form

      click_button "Submit"

      page.should have_content "Data extract found 2 rows"

      click_button "Download Report"

      page.response_headers['Content-Type'].should include('text/csv')
    end

  end

  private

  def navigate_to_loan_audit_report_form
    visit root_path
    click_link 'Generate Loan Audit Report'
  end

end
