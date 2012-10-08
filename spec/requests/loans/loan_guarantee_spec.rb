# encoding: utf-8

require 'spec_helper'

describe 'loan guarantee' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :offered, lender: current_user.lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Guarantee & Initial Draw'

    choose_radio_button 'received_declaration', true
    choose_radio_button 'signed_direct_debit_received', true
    choose_radio_button 'first_pp_received', true
    fill_in 'initial_draw_date', '28/02/12'
    fill_in 'initial_draw_amount', '£10,000.42'
    fill_in 'maturity_date', '01/03/12'

    click_button 'Submit'

    loan = Loan.last!

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Guaranteed
    loan.received_declaration.should == true
    loan.signed_direct_debit_received.should == true
    loan.first_pp_received.should == true
    loan.maturity_date.should == Date.new(2012, 3, 1)
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Guaranteed, 7, current_user)

    loan_change = loan.initial_draw_change
    loan_change.amount_drawn.should == Money.new(10_000_42)
    loan_change.change_type_id.should == nil
    loan_change.created_by.should == current_user
    loan_change.date_of_change.should == Date.new(2012, 2, 28)
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

  private
  def choose_radio_button(attribute, value)
    choose "loan_guarantee_#{attribute}_#{value}"
  end

  def fill_in(attribute, value)
    page.fill_in "loan_guarantee_#{attribute}", with: value
  end
end
