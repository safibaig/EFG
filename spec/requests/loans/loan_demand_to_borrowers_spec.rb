# encoding: utf-8

require 'spec_helper'

describe 'loan demand to borrower' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender) }

  before do
    initial_draw_change = loan.initial_draw_change
    initial_draw_change.amount_drawn = loan.amount
    initial_draw_change.date_of_change = Date.new(2012)
    initial_draw_change.save!

    login_as(current_user, scope: :user)
  end

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Demand to Borrower'

    fill_in_valid_demand_to_borrower_details
    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::LenderDemand
    loan.borrower_demanded_on.should == Date.today
    loan.amount_demanded.should == Money.new(10_000_00) # 10000.00
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::LenderDemand, 10, current_user)

    demand_to_borrower = loan.demand_to_borrowers.last!
    demand_to_borrower.created_by.should == current_user
    demand_to_borrower.date_of_demand.should == Date.today
    demand_to_borrower.demanded_amount.should == Money.new(10_000_00)
    demand_to_borrower.modified_date.should == Date.current
  end

  it 'does not display previous DemandToBorrow details' do
    loan.update_attribute(:amount_demanded, 1234)

    visit loan_path(loan)
    click_link 'Demand to Borrower'
    page.find('#loan_demand_to_borrower_amount_demanded').value.should be_blank
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Demand to Borrower'

    loan.state.should == Loan::Guaranteed
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_demand_to_borrower_path(loan)
  end

end
