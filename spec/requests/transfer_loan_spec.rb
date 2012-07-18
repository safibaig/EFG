require 'spec_helper'

describe 'Transfer a loan' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :sflg) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit root_path
    click_link 'Transfer a loan'
  end

  it 'should transfer loan from one lender to another' do
    fill_in 'loan_transfer_reference', with: loan.reference
    fill_in 'loan_transfer_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_facility_letter_date', with: loan.facility_letter_date.strftime('%d/%m/%Y')
    fill_in 'loan_transfer_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content('This page provides confirmation that the loan has been transferred.')

    # Check original loan and new loan
    loan.reload.state.should == Loan::RepaidFromTransfer
    transferred_loan = Loan.last
    transferred_loan.reference.should == LoanReference.new(loan.reference).increment
    transferred_loan.state.should == Loan::Incomplete
    transferred_loan.business_name.should == loan.business_name
    transferred_loan.amount.should == loan.amount - Money.new(500)

    # update transferred loan entry
    click_link 'Loan Entry'

    choose 'transferred_loan_entry_declaration_signed_true'
    fill_in 'transferred_loan_entry_branch_sortcode', with: '03-12-45'
    choose 'transferred_loan_entry_repayment_frequency_id_1'
    fill_in "transferred_loan_entry_repayment_duration_years", with: 1
    fill_in "transferred_loan_entry_repayment_duration_months", with: 6
    fill_in 'transferred_loan_entry_maturity_date', with: '01/01/2013'

    click_button 'State Aid Calculation'
    page.fill_in 'state_aid_calculation_initial_draw_year', with: '2012'
    page.fill_in 'state_aid_calculation_initial_draw_amount', with: '7000'
    page.fill_in 'state_aid_calculation_initial_draw_months', with: '12'
    click_button 'Submit'

    fill_in 'transferred_loan_entry_generic1', with: 'Generic 1'
    fill_in 'transferred_loan_entry_generic2', with: 'Generic 2'
    fill_in 'transferred_loan_entry_generic3', with: 'Generic 3'
    fill_in 'transferred_loan_entry_generic4', with: 'Generic 4'
    fill_in 'transferred_loan_entry_generic5', with: 'Generic 5'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Completed
    loan.declaration_signed.should be_true
    loan.branch_sortcode.should == '03-12-45'
    loan.amount.should == transferred_loan.amount
    loan.maturity_date.should == Date.new(2013, 1, 1)
    loan.repayment_frequency_id.should == 1
    loan.repayment_duration.should == MonthDuration.new(18)
    loan.generic1.should == 'Generic 1'
    loan.generic2.should == 'Generic 2'
    loan.generic3.should == 'Generic 3'
    loan.generic4.should == 'Generic 4'
    loan.generic5.should == 'Generic 5'
    loan.state_aid_calculation.should be_present
  end

  it 'should display error when loan to transfer is not found' do
    fill_in 'loan_transfer_reference', with: 'wrong'
    fill_in 'loan_transfer_amount', with: loan.amount.to_s
    fill_in 'loan_transfer_facility_letter_date', with: loan.facility_letter_date.strftime('%d/%m/%Y')
    fill_in 'loan_transfer_new_amount', with: loan.amount - Money.new(500)
    choose 'loan_transfer_declaration_signed_true'

    click_button 'Transfer Loan'

    page.should have_content(I18n.t("activemodel.errors.models.loan_transfer.attributes.base.cannot_be_transferred"))
  end

end
