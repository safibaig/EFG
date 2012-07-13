require 'spec_helper'

describe 'Transfer a loan' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  it 'should transfer loan from one lender to another' do
    # click_link 'Transfer a loan'
    visit new_loan_transfer_path

    fill_in 'loan_transfer_reference', with: loan.reference
    fill_in 'loan_transfer_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_facility_letter_date', with: loan.facility_letter_date
    fill_in 'loan_transfer_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content('This page provides confirmation that the loan has been transferred.')

    loan.reload.state.should == Loan::RepaidFromTransfer

    transferred_loan = Loan.last
    transferred_loan.state.should == Loan::Incomplete
    transferred_loan.business_name.should == loan.business_name
  end

  it 'should display error when loan to transfer is not found' do
    visit new_loan_transfer_path

    fill_in 'loan_transfer_reference', with: 'wrong'
    fill_in 'loan_transfer_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_facility_letter_date', with: loan.facility_letter_date
    fill_in 'loan_transfer_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content('Could not find the specified loan, please check the data you have entered')
  end

end
