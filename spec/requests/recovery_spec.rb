# encoding: utf-8

require 'spec_helper'

describe 'loan recovery' do
  let(:loan) { FactoryGirl.create(:loan, :settled) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  it 'creates a loan recovery' do
    visit loan_path(loan)
    click_link 'Recovery Made'
    fill_in_valid_details

    expect {
      click_button 'Submit'
    }.to change(Recovery, :count).by(1)

    verify_recovery_and_loan

    current_path.should == loan_path(loan)
  end

  it 'works for an already recovered loan' do
    loan.update_attribute :state, Loan::Recovered
    visit loan_path(loan)
    click_link 'Recovery Made'
    fill_in_valid_details

    expect {
      click_button 'Submit'
    }.to change(Recovery, :count).by(1)

    verify_recovery_and_loan

    current_path.should == loan_path(loan)
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Recovery Made'

    expect {
      click_button 'Submit'
      loan.reload
    }.to_not change(loan, :state)

    current_path.should == loan_recoveries_path(loan)
  end

  private
    def fill_in(attribute, value)
      page.fill_in "recovery_#{attribute}", with: value
    end

    def fill_in_valid_details
      fill_in 'recovered_on', '1/6/12'
    end

    def verify_recovery_and_loan
      recovery = Recovery.last
      recovery.recovered_on.should == Date.new(2012, 6, 1)

      loan.reload
      loan.state.should == Loan::Recovered
      loan.recovery_on.should == Date.new(2012, 6, 1)
    end
end
