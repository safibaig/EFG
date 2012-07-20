# encoding: utf-8

require 'spec_helper'

describe 'loan demand to borrower' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Demand to Borrower'

    fill_in 'borrower_demanded_on', '1/6/12'
    fill_in 'borrower_demand_outstanding', '£5,000'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::LenderDemand
    loan.borrower_demanded_on.should == Date.new(2012, 6, 1)
    loan.borrower_demand_outstanding.should == Money.new(5_000_00) # 5000.00
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

  private
  def fill_in(attribute, value)
    page.fill_in "loan_demand_to_borrower_#{attribute}", with: value
  end
end
