require 'spec_helper'

describe 'loan cancel' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, lender: current_user.lender) }
  before { login_as(current_user, scope: :user) }

  [
    Loan::Completed,
    Loan::Eligible,
    Loan::Incomplete,
    Loan::Offered
  ].each do |state|
    it "works from #{state} state" do
      loan.update_attribute :state, state

      visit loan_path(loan)
      click_link 'Cancel Loan'

      fill_in 'cancelled_on', '1/6/12'
      select CancelReason.find(4).name, from: 'loan_cancel_cancelled_reason_id'
      fill_in 'cancelled_comment', 'No comment'

      click_button 'Submit'

      loan = Loan.last
      loan.state.should == Loan::Cancelled
      loan.cancelled_on.should == Date.new(2012, 6, 1)
      loan.cancelled_reason_id.should == 4
      loan.cancelled_comment.should == 'No comment'
      loan.modified_by.should == current_user

      should_log_loan_state_change(loan, Loan::Cancelled, 3)
    end
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
