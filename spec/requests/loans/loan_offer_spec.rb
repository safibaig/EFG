require 'spec_helper'

describe 'loan offer' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:lending_limit) { FactoryGirl.create(:lending_limit) }
  let(:loan) { FactoryGirl.create(:loan, :completed, lender: current_user.lender, lending_limit: lending_limit) }
  before { login_as(current_user, scope: :user) }

  def dispatch
    visit loan_path(loan)
    click_link 'Offer Scheme Facility'
  end

  it 'entering further loan information' do
    dispatch
    fill_in_valid_loan_offer_details(loan)
    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Offered
    loan.facility_letter_date.should == Date.today
    loan.facility_letter_sent.should == true
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Offered, 5, current_user)
  end

  it 'does not continue with invalid values' do
    dispatch

    loan.state.should == Loan::Completed
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_offer_path(loan)
  end

  context "with an unavailable lending limit" do
    let(:lending_limit) { FactoryGirl.create(:lending_limit, :inactive) }

    it "prompts to change the lending limit" do
      dispatch

      page.should have_content 'Lending Limit Unavailable'
    end
  end
end
