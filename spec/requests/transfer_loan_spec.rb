require 'spec_helper'

describe 'Transfer a loan' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let(:loan) { FactoryGirl.create(:loan) }

  before(:each) do
    login_as(current_user, scope: :user)
  end

  it 'should transfer loan from one lender to another' do
    click_link 'Transfer a loan'

    fill_in 'transfer_loan_reference', with: loan.reference
    fill_in 'transfer_loan_amount', with: loan.amount.to_s
    fill_in 'transfer_loan_facility_letter_date', with: loan.facility_letter_date
    fill_in 'transfer_loan_new_amount', with: loan.amount - Money.new(500)
    check 'transfer_loan_declaration_signed'

    click_button 'Transfer Loan'

    page.should have_content('This page provides confirmation that the loan has been transferred.')

    loan.reload.state.should == Loan::RepaidFromTransfer

    transferred_loan = Loan.last
    transferred_loan.state.should == Loan::Incomplete
    transferred_loan.business_name.should == loan.business_name
  end

end
