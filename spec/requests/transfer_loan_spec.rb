require 'spec_helper'

describe 'Transfer a loan' do
  let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: lender) }
  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :sflg) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit root_path
    click_link 'Transfer a Loan'
  end

  it 'should transfer loan from one lender to another' do
    fill_in 'loan_transfer_sflg_reference', with: loan.reference
    fill_in 'loan_transfer_sflg_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_sflg_facility_letter_date', with: loan.facility_letter_date.strftime('%d/%m/%Y')
    fill_in 'loan_transfer_sflg_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_sflg_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content('This page provides confirmation that the loan has been transferred.')

    # Check original loan and new loan
    loan.reload
    loan.state.should == Loan::RepaidFromTransfer
    loan.modified_by.should == current_user

    transferred_loan = Loan.last
    transferred_loan.transferred_from_id.should == loan.id
    transferred_loan.reference.should == LoanReference.new(loan.reference).increment
    transferred_loan.state.should == Loan::Incomplete
    transferred_loan.business_name.should == loan.business_name
    transferred_loan.amount.should == loan.amount - Money.new(500)
    transferred_loan.created_by.should == current_user
    transferred_loan.modified_by.should == current_user

    # verify correct loan entry form is shown
    click_link 'Loan Entry'
    current_path.should == new_loan_transferred_entry_path(transferred_loan)
  end

  it 'should display error when loan to transfer is not found' do
    fill_in 'loan_transfer_sflg_reference', with: 'wrong'
    fill_in 'loan_transfer_sflg_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_sflg_facility_letter_date', with: loan.facility_letter_date.strftime('%d/%m/%Y')
    fill_in 'loan_transfer_sflg_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_sflg_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content(I18n.t("activemodel.errors.models.loan_transfer/sflg.attributes.base.cannot_be_transferred"))
  end

  it 'should display error when loan to transfer is an EFG loan' do
    # change loan to EFG scheme
    loan.loan_scheme = 'E'
    loan.save!

    fill_in 'loan_transfer_sflg_reference', with: loan.reference
    fill_in 'loan_transfer_sflg_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_sflg_facility_letter_date', with: loan.facility_letter_date.strftime('%d/%m/%Y')
    fill_in 'loan_transfer_sflg_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_sflg_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content(I18n.t("activemodel.errors.models.loan_transfer/sflg.attributes.base.cannot_be_transferred"))
  end

end
