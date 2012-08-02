require 'spec_helper'

describe 'Loan report' do

  let!(:loan1) { FactoryGirl.create(:loan, :eligible) }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }

  context 'as a lender user' do

    let(:current_user) { FactoryGirl.create(:lender_user, lender: loan1.lender) }

    before(:each) do
      login_as(current_user, scope: :user)
    end

    it "should output a CSV report for that specific lender" do
      visit new_loan_report_path

      click_button "Submit"

      page.should have_content "Data extract found 1 row"

      click_button "Download Report"

      # verify CSV is rendered
      page.body.should include(LoanCsvExport.new([loan1]).generate)
    end

    it "should only allow selection of loans created by any user belonging to that lender" do
      another_user = FactoryGirl.create(:lender_user, lender: loan1.lender, first_name: "Peter", last_name: "Parker")
      loan1.update_attribute(:created_by_id, another_user.id)

      visit new_loan_report_path

      loan1.lender.users.each do |user|
        page.should have_css("#loan_report_created_by_id option", text: user.name)
      end

      loan2.lender.users.each do |another_lender_user|
        page.should_not have_css("#loan_report_created_by_id option", text: another_lender_user.name)
      end

      select "Peter Parker", from: "loan_report[created_by_id]"
      click_button "Submit"

      page.should have_content "Data extract found 1 row"
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

    # TODO: update spec to confirm cfe admin, auditor and premium collection users are shown
    it "should only allow selection of loans created by any Cfe admin, Cfe, Auditor or Premium collection agent user" do
      another_cfe_user = FactoryGirl.create(:cfe_user, first_name: "Mr", last_name: "Admin")

      visit new_loan_report_path

      [current_user, another_cfe_user].each do |user|
        page.should have_css("#loan_report_created_by_id option", text: user.name)
      end

      (loan1.lender.users & loan2.lender.users).each do |lender_user|
        page.should_not have_css("#loan_report_created_by_id option", text: lender_user.name)
      end

      select loan1.lender.name, from: 'loan_report_lender_ids'
      select "Mr Admin", from: "loan_report[created_by_id]"
      click_button "Submit"

      # another_cfe_user did not create any loans
      page.should have_content "Data extract found 0 rows"
    end

  end

end
