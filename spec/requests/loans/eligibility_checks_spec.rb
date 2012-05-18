require 'spec_helper'

describe 'eligibility checks' do
  it 'creates a loan from valid eligibility values' do
    visit root_path
    click_link 'Check Eligibility'

    choose_radio_button 'viable_proposition', true
    choose_radio_button 'would_you_lend', true
    choose_radio_button 'collateral_exhausted', true
    fill_in 'amount', 1234567.89
    choose_radio_button 'lender_cap', 1
    fill_in_duration_input 'repayment_duration', 2, 6
    fill_in 'turnover', 1234567.89
    fill_in 'trading_date', 2.years.ago.strftime('%d/%m/%Y')
    fill_in 'sic_code', 'DA15.61/1'
    choose_radio_button 'loan_category', 2
    choose_radio_button 'reason', 3
    choose_radio_button 'previous_borrowing', true
    choose_radio_button 'private_residence_charge_required', false
    choose_radio_button 'personal_guarantee_required', true

    click_button 'Check'

    current_path.should == loan_path(Loan.last)
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
