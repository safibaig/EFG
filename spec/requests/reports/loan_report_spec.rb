require 'spec_helper'

describe 'Loan report' do

  let!(:loan1) { FactoryGirl.create(:loan, :eligible) }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }

  context 'as a lender user' do

    let(:current_user) { FactoryGirl.create(:lender_user, lender: loan1.lender) }

    before(:each) do
      login_as(current_user, scope: :user)
      visit new_loan_report_path
    end

    it "should output a CSV report for that specific lender" do
      click_button "Submit"

      page.should have_content "Data extract found 1 row"

      click_button "Download Report"

      # verify CSV is rendered
      page.body.should include(LoanCsvExport.new([loan1]).generate)
    end

    it "should return validation errors" do
      fill_in 'loan_report_facility_letter_start_date', with: 'wrong'
      click_button "Submit"

      page.should have_content I18n.t('simple_form.labels.loan_report.facility_letter_start_date')
      page.should have_content "is invalid"
    end

  end

  context "as a CFE user" do

    let!(:loan3) { FactoryGirl.create(:loan) }

    let!(:current_user) { FactoryGirl.create(:cfe_user) }

    before(:each) do
      login_as(current_user, scope: :user)
      visit new_loan_report_path
    end

    it "should output a CSV report for a selection of lenders" do
      select loan1.lender.name, from: 'loan_report_lender_ids'
      select loan3.lender.name, from: 'loan_report_lender_ids'
      click_button "Submit"

      page.should have_content "Data extract found 2 rows"

      click_button "Download Report"

      # verify CSV is rendered
      page.body.should include(LoanCsvExport.new([loan1, loan3]).generate)
    end

  end

end
