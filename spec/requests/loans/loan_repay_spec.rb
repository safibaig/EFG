require 'spec_helper'

describe 'loan repay' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender) }
  before { login_as(current_user, scope: :user) }

  it 'repays a loan' do
    visit loan_path(loan)
    click_link 'Repay Loan'

    fill_in 'repaid_on', '1/6/12'
    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Repaid
    loan.repaid_on.should == Date.new(2012, 6, 1)
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Repaid, 14, current_user)
  end

  it 'repays a LenderDemand loan' do
    loan.update_attribute :state, Loan::LenderDemand
    visit loan_path(loan)
    click_link 'Repay Loan'

    fill_in 'repaid_on', '1/6/12'
    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Repaid
    loan.repaid_on.should == Date.new(2012, 6, 1)
    loan.modified_by.should == current_user
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Repay Loan'

    loan.state.should == Loan::Guaranteed
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_repay_path(loan)
  end

  private
  def fill_in(attribute, value)
    page.fill_in "loan_repay_#{attribute}", with: value
  end
end
