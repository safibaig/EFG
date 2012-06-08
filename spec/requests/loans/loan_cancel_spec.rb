require 'spec_helper'

describe 'loan cancel' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :eligible, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Cancel Loan'

    fill_in 'cancelled_on', '1/6/2012'
    choose_radio_button 'cancelled_reason', 4
    fill_in 'cancelled_comment', 'No comment'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Cancelled
    loan.cancelled_on.should == Date.new(2012, 6, 1)
    loan.cancelled_reason.should == 4
    loan.cancelled_comment.should == 'No comment'
  end

  it 'cancels an incomplete loan' do
    loan.update_attribute :state, Loan::Incomplete
    visit loan_path(loan)
    click_link 'Cancel Loan'

    fill_in 'cancelled_on', '1/6/2012'
    choose_radio_button 'cancelled_reason', 4
    fill_in 'cancelled_comment', 'No comment'

    click_button 'Submit'

    Loan.last.state.should == Loan::Cancelled
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Cancel Loan'

    loan.state.should == Loan::Eligible
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_cancel_path(loan)
  end

  private
  def choose_radio_button(attribute, value)
    choose "loan_cancel_#{attribute}_#{value}"
  end

  def fill_in(attribute, value)
    page.fill_in "loan_cancel_#{attribute}", with: value
  end
end
