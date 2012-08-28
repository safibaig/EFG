require 'spec_helper'

describe 'eligibility checks' do
  let(:user) { FactoryGirl.create(:lender_user) }
  before { login_as(user, scope: :user) }

  it 'creates a loan from valid eligibility values' do
    visit root_path
    click_link 'New Loan Application'

    choose_radio_button 'viable_proposition', true
    choose_radio_button 'would_you_lend', true
    choose_radio_button 'collateral_exhausted', true
    fill_in 'amount', '50000.89'
    select LoanAllocation.last.lender.name, from: 'loan_eligibility_check_loan_allocation_id'
    fill_in_duration_input 'repayment_duration', 2, 6
    fill_in 'turnover', '1234567.89'
    fill_in 'trading_date', '31/1/2012'
    fill_in 'sic_code', 'DA15.61/1'
    select LoanCategory.find(2).name, from: 'loan_eligibility_check_loan_category_id'
    select LoanReason.find(3).name, from: 'loan_eligibility_check_reason_id'
    choose_radio_button 'previous_borrowing', true
    choose_radio_button 'private_residence_charge_required', false
    choose_radio_button 'personal_guarantee_required', false

    expect {
      click_button 'Check'
    }.to change(Loan, :count).by(1)

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.state.should == Loan::Eligible
    loan.viable_proposition.should be_true
    loan.would_you_lend.should be_true
    loan.collateral_exhausted.should be_true
    loan.amount.should == Money.new(5000089)
    loan.loan_allocation.should be_instance_of(LoanAllocation)
    loan.repayment_duration.should == MonthDuration.new(30)
    loan.turnover.should == Money.new(123456789)
    loan.trading_date.should == Date.new(2012, 1, 31)
    loan.sic_code.should == 'DA15.61/1'
    loan.loan_category_id.should == 2
    loan.reason_id.should == 3
    loan.previous_borrowing.should be_true
    loan.private_residence_charge_required.should be_false
    loan.personal_guarantee_required.should be_false
    loan.loan_scheme.should == Loan::EFG_SCHEME
    loan.loan_source.should == Loan::SFLG_SOURCE
    loan.created_by.should == user
    loan.modified_by.should == user

    should_log_loan_state_change(loan, Loan::Eligible, 1)
  end

  it 'does not create an invalid loan' do
    visit root_path
    click_link 'New Loan Application'

    expect {
      click_button 'Check'
    }.not_to change(Loan, :count)

    current_path.should == '/loans/eligibility_check'
  end

  private
    def choose_radio_button(attribute, value)
      choose "loan_eligibility_check_#{attribute}_#{value}"
    end

    def fill_in(attribute, value)
      page.fill_in "loan_eligibility_check_#{attribute}", with: value
    end

    def fill_in_duration_input(attribute, years, months)
      fill_in "#{attribute}_years", years
      fill_in "#{attribute}_months", months
    end
end
