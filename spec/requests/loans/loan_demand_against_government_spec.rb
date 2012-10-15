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

    page.should have_content(I18n.t('activemodel.loan_demand_against_government.amount_claimed', amount: loan.dti_amount_claimed.format))

    loan.state.should == Loan::Demanded
    loan.dti_demand_outstanding.should == loan.amount
    loan.dti_amount_claimed.should_not be_nil
    loan.dti_demanded_on.should == Date.today
    loan.ded_code.should == ded_code
    loan.dti_reason.should == 'Something'
    loan.modified_by.should == current_user

    should_log_loan_state_change(loan, Loan::Demanded, 13, current_user)
  end

  it 'requires extra data when non-EFG loan' do
    loan = FactoryGirl.create(:loan, :sflg, :guaranteed, :lender_demand, lender: current_lender)

    visit loan_path(loan)
    click_link 'Demand Against Guarantee'

    fill_in 'dti_demand_outstanding', loan.amount
    fill_in 'dti_reason', 'Something'
    fill_in 'dti_interest', 5000
    fill_in 'dti_break_costs', 2000
    select ded_code.code, from: 'loan_demand_against_government_dti_ded_code'

    click_button 'Submit'

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.dti_interest.should == Money.new(5000_00)
    loan.dti_break_costs.should == Money.new(2000_00)
    loan.dti_amount_claimed.should_not be_nil
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
