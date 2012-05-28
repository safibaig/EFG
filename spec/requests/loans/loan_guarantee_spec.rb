require 'spec_helper'

describe 'loan guarantee' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :offered, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit new_loan_guarantee_path(loan)

    choose_radio_button 'received_declaration', true
    choose_radio_button 'signed_direct_debit_received', true
    choose_radio_button 'first_pp_received', true
    fill_in 'initial_draw_date', '28/02/2012'
    fill_in 'initial_draw_value', '10000.42'
    fill_in 'maturity_date', '01/03/2012'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Guaranteed
    loan.received_declaration.should == true
    loan.signed_direct_debit_received.should == true
    loan.first_pp_received.should == true
    loan.initial_draw_date.should == Date.new(2012, 2, 28)
    loan.initial_draw_value.should == Money.new(1000042)
    loan.maturity_date.should == Date.new(2012, 3, 1)
  end

  it 'does not continue with invalid values' do
    pending "Don't know what makes this form invalid yet."
  end

  private
  def choose_radio_button(attribute, value)
    choose "loan_guarantee_#{attribute}_#{value}"
  end

  def fill_in(attribute, value)
    page.fill_in "loan_guarantee_#{attribute}", with: value
  end
end
