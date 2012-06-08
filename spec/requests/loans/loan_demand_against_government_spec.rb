# encoding: utf-8

require 'spec_helper'

describe 'loan demand against government' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender) }
  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Demand Against Guarantee Guarantee'

    fill_in 'dti_demand_outstanding', '£10,000.42'
    fill_in 'dti_reason', 'Something'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Demanded
    loan.dti_demanded_on.should == Date.today
    loan.dti_demand_outstanding.should == Money.new(10_000_42) # £10,000.42
    loan.dti_reason.should == 'Something'
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Demand Against Guarantee Guarantee'

    loan.state.should == Loan::LenderDemand
    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_demand_against_government_path(loan)
  end

  private
  def fill_in(attribute, value)
    page.fill_in "loan_demand_against_government_#{attribute}", with: value
  end
end
