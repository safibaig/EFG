require 'spec_helper'

describe 'Loan report' do

  let!(:loan1) { FactoryGirl.create(:loan, :eligible) }

  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  context 'as a lender user' do

    let(:current_user) { FactoryGirl.create(:lender_user, lender: loan1.lender) }

    before(:each) do
      login_as(current_user, scope: :user)
    end

    it "should output a CSV report for that specific lender" do
      navigate_to_loan_report_form

      fill_in_valid_details
      click_button "Submit"

      page.should have_content "Data extract found 1 row"

      click_button "Download Report"

      page.response_headers['Content-Type'].should include('text/csv')
    end

    it "should only allow selection of loans created by any user belonging to that lender" do
      another_user = FactoryGirl.create(:lender_user, lender: loan1.lender, first_name: "Peter", last_name: "Parker")
      loan1.update_attribute(:created_by_id, another_user.id)

      navigate_to_loan_report_form

      loan1.lender.lender_users.each do |user|
        page.should have_css("#loan_report_created_by_id option", text: user.name)
      end

      loan2.lender.lender_users.each do |another_lender_user|
        page.should_not have_css("#loan_report_created_by_id option", text: another_lender_user.name)
      end

      fill_in_valid_details
      select "Peter Parker", from: "loan_report[created_by_id]"
      click_button "Submit"

      page.should have_content "Data extract found 1 row"
    end
  end

  context "as a CFE user" do

    let!(:loan3) { FactoryGirl.create(:loan) }

    let!(:current_user) { FactoryGirl.create(:cfe_user) }

    it "should output a CSV report for a selection of lenders" do
      navigate_to_loan_report_form

      fill_in_valid_details
      select loan1.lender.name, from: 'loan_report_lender_ids'
      select loan3.lender.name, from: 'loan_report_lender_ids'
      click_button "Submit"

      page.should have_content "Data extract found 2 rows"

      click_button "Download Report"

      page.response_headers['Content-Type'].should include('text/csv')
    end

    it "should not show created by form field" do
      navigate_to_loan_report_form
      page.should_not have_css("#loan_report_created_by_id option")
    end

    it "should show validation errors" do
      navigate_to_loan_report_form
      click_button "Submit"

      # 2 errors - empty states multi-select, no loan source checkbox checked
      page.should have_css('.control-group.select.required.error #loan_report_lender_ids')
      page.should have_css('.control-group.check_boxes.required.error #loan_report_loan_sources_s')
    end

  end

  private

  def fill_in_valid_details
    select 'Eligible', from: 'loan_report[states][]'
    select 'Guaranteed', from: 'loan_report[states][]'
    check :loan_report_loan_source_s
  end

  def navigate_to_loan_report_form
    visit root_path
    click_link 'Generate a loan report'
  end

end
