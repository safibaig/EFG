require 'spec_helper'

describe 'Loan details' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) { FactoryGirl.create(:loan, :transferred, lender: current_user.lender) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  it 'can export loan data as CSV from loan summary page' do
    visit loan_path(loan)

    click_link "Export CSV"

    page.current_url.should == loan_url(loan, format: 'csv')
  end

  it 'can export loan data as CSV from loan details page' do
    visit details_loan_path(loan)

    click_link "Export CSV"

    page.current_url.should == details_loan_url(loan, format: 'csv')
  end

end
