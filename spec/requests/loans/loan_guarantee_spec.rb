# encoding: utf-8

require 'spec_helper'

describe 'loan guarantee' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) {
    FactoryGirl.create(:loan, :offered, :with_state_aid_calculation,
      lender: current_user.lender,
      repayment_duration: {years: 3},
      facility_letter_date: Date.new(2012, 10, 20)
    )
  }

  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Guarantee & Initial Draw'

    fill_in_valid_loan_guarantee_details(initial_draw_date: '30/11/2012')
    click_button 'Submit'

    loan = Loan.last!

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Guaranteed
    loan.received_declaration.should == true
    loan.signed_direct_debit_received.should == true
    loan.first_pp_received.should == true
    loan.maturity_date.should == Date.new(2015, 12, 1)
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Guaranteed, 7, current_user)

    loan_change = loan.initial_draw_change
    loan_change.amount_drawn.should == loan.amount
    loan_change.change_type_id.should == nil
    loan_change.created_by.should == current_user
    loan_change.date_of_change.should == Date.new(2012, 11, 30)
    loan_change.modified_date.should == Date.current
    loan_change.seq.should == 0
  end

  it 'does not continue with invalid values' do
    visit new_loan_guarantee_path(loan)

    loan.state.should == Loan::Offered
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == "/loans/#{loan.id}/guarantee"
  end

end
