# encoding: utf-8

require 'spec_helper'

describe 'loan change' do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, business_name: 'ACME') }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  before(:each) do
    visit loan_path(loan)
    click_link 'Change Amount or Terms'
  end

  it 'works' do
    fill_in_valid_details

    expect {
      click_button 'Submit'
    }.to change(LoanChange, :count).by(1)

    verify

    current_path.should == loan_path(loan)
  end

  it 'does not continue with invalid values' do
    click_button 'Submit'
    current_path.should == loan_loan_changes_path(loan)
  end

  it 'requires recalculation of state aid' do
    fill_in_valid_details
    click_button "Reschedule"

    fill_in "state_aid_calculation_premium_cheque_month", with: "09/2012"
    fill_in "state_aid_calculation_initial_draw_amount", with: "30000"
    fill_in "state_aid_calculation_initial_draw_months", with: "18"

    click_button "Submit"

    current_path.should == new_loan_loan_change_path(loan)

    # verify previous values are remembered when returning to loan change form
    page.find('#loan_change_date_of_change').value.should == '01/06/2012'
    page.find('#loan_change_change_type_id').value.should == '1'
    page.find('#loan_change_amount_drawn').value.should == '15000.00'
    page.find('#loan_change_business_name').value.should == 'updated'

    # choose change type that requires state aid recalculation
    select ChangeType.find('2').name, from: 'loan_change_change_type_id'

    expect {
      click_button 'Submit'
    }.to change(StateAidCalculation, :count).by(1)
  end

  private

    def fill_in_valid_details
      fill_in 'loan_change_date_of_change', with: '1/6/12'
      select ChangeType.find('1').name, from: 'loan_change_change_type_id'
      fill_in 'loan_change_amount_drawn', with: '£15,000'
      fill_in 'loan_change_business_name', with: 'updated'
    end

    def verify
      loan_change = loan.loan_changes.last
      loan_change.date_of_change.should == Date.new(2012, 6, 1)
      loan_change.change_type.should == ChangeType.find('1')
      loan_change.amount_drawn.should == Money.new(15_000_00)
      loan_change.old_business_name.should == 'ACME'
      loan_change.business_name.should == 'updated'

      loan.reload
      loan.business_name.should == 'updated'
    end
end
