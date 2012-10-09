# encoding: utf-8

require 'spec_helper'

describe 'loan demand against government' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, :lender_demand, lender: current_lender) }
  let!(:ded_code) { FactoryGirl.create(:ded_code) }

  before { login_as(current_user, scope: :user) }

  it 'entering further loan information' do
    visit loan_path(loan)
    click_link 'Demand Against Guarantee'

    fill_in 'dti_demand_outstanding', loan.amount
    fill_in 'dti_reason', 'Something'
    select ded_code.code, from: 'loan_demand_against_government_dti_ded_code'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Demanded
    loan.dti_demand_outstanding.should == loan.amount
    loan.dti_demanded_on.should == Date.today
    loan.ded_code.should == DedCode.find_by_code('A.10.10')
    loan.dti_reason.should == 'Something'
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Demanded, 13, current_user)
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Demand Against Guarantee'

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
