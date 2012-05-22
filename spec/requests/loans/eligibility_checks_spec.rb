require 'spec_helper'

describe 'eligibility checks' do
  before do
    user = FactoryGirl.create(:user)
    login_as(user, scope: :user)
  end

  it 'creates a loan from valid eligibility values' do
    visit root_path
    click_link 'Check Eligibility'

    choose_radio_button 'viable_proposition', true
    choose_radio_button 'would_you_lend', true
    choose_radio_button 'collateral_exhausted', true
    fill_in 'amount', 1234567.89
    choose_radio_button 'lender_cap_id', 1
    fill_in_duration_input 'repayment_duration', 2, 6
    fill_in 'turnover', 1234567.89
    fill_in 'trading_date', '31/1/2012'
    fill_in 'sic_code', 'DA15.61/1'
    choose_radio_button 'loan_category_id', 2
    choose_radio_button 'reason_id', 3
    choose_radio_button 'previous_borrowing', true
    choose_radio_button 'private_residence_charge_required', false
    choose_radio_button 'personal_guarantee_required', true

    expect {
      click_button 'Check'
    }.to change(Loan, :count).by(1)

    loan = Loan.last

    current_path.should == loan_path(loan)

    loan.viable_proposition.should be_true
    loan.would_you_lend.should be_true
    loan.collateral_exhausted.should be_true
    loan.amount.should == Money.new(123456789)
    loan.lender_cap_id.should == 1
    loan.repayment_duration.should == MonthDuration.new(30)
    loan.turnover.should == Money.new(123456789)
    loan.trading_date.should == Date.new(2012, 1, 31)
    loan.sic_code.should == 'DA15.61/1'
    loan.loan_category_id.should == 2
    loan.reason_id.should == 3
    loan.previous_borrowing.should be_true
    loan.private_residence_charge_required.should be_false
    loan.personal_guarantee_required.should be_true
  end

  it 'does not create an invalid loan' do
    visit root_path
    click_link 'Check Eligibility'

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
