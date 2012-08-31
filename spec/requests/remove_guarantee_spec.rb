require 'spec_helper'

describe 'Remove guarantee' do

  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  before do
    login_as(current_user, scope: :user)
  end

  it 'should remove guarantee from loan' do
    visit loan_path(loan)
    click_link 'Remove guarantee'

    fill_in 'loan_remove_guarantee_remove_guarantee_on', with: '20/05/2012'
    fill_in 'loan_remove_guarantee_remove_guarantee_outstanding_amount', with: '10000'
    fill_in 'loan_remove_guarantee_remove_guarantee_reason', with: 'n/a/'
    click_button 'Remove Guarantee'

    page.should have_content('The Guarantee has been removed in respect of this facility.')

    loan.reload
    loan.state.should == Loan::Removed
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Removed, 15)
  end

end
