require 'spec_helper'

describe 'loan no claim' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_user.lender) }
  before { login_as(current_user, scope: :user) }

  it 'progresses a loan to NotDemanded' do
    visit loan_path(loan)
    click_link 'No Claim'

    fill_in 'no_claim_on', '1/6/12'
    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::NotDemanded
    loan.no_claim_on.should == Date.new(2012, 6, 1)
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::NotDemanded, 11, current_user)
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'No Claim'

    loan.state.should == Loan::LenderDemand
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_no_claim_path(loan)
  end

  private
  def fill_in(attribute, value)
    page.fill_in "loan_no_claim_#{attribute}", with: value
  end
end
