require 'spec_helper'

describe 'Transferred loan entry' do

  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) { FactoryGirl.create(:loan, :transferred, lender: current_user.lender) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit new_loan_transferred_entry_path(loan)
  end

  it 'should transition transferred loan to completed' do
    choose 'transferred_loan_entry_declaration_signed_true'
    fill_in 'transferred_loan_entry_sortcode', with: '03-12-45'
    select 'Quarterly', from: 'transferred_loan_entry_repayment_frequency_id'
    fill_in 'transferred_loan_entry_lender_reference', with: 'lenderref1'
    fill_in "transferred_loan_entry_repayment_duration_years", with: 1
    fill_in "transferred_loan_entry_repayment_duration_months", with: 6

    calculate_state_aid(loan)

    fill_in 'transferred_loan_entry_generic1', with: 'Generic 1'
    fill_in 'transferred_loan_entry_generic2', with: 'Generic 2'
    fill_in 'transferred_loan_entry_generic3', with: 'Generic 3'
    fill_in 'transferred_loan_entry_generic4', with: 'Generic 4'
    fill_in 'transferred_loan_entry_generic5', with: 'Generic 5'

    click_button 'Submit'

    current_path.should == loan_path(loan)

    loan.reload
    loan.state.should == Loan::Completed
    loan.declaration_signed.should be_true
    loan.sortcode.should == '03-12-45'
    loan.lender_reference.should == 'lenderref1'
    loan.repayment_frequency_id.should == 3
    loan.repayment_duration.should == MonthDuration.new(18)
    loan.generic1.should == 'Generic 1'
    loan.generic2.should == 'Generic 2'
    loan.generic3.should == 'Generic 3'
    loan.generic4.should == 'Generic 4'
    loan.generic5.should == 'Generic 5'
    loan.premium_schedule.should be_present
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Completed, 4, current_user)
  end

end
