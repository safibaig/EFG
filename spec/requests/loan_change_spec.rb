# encoding: utf-8

require 'spec_helper'

describe 'loan change' do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, business_name: 'ACME') }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  it 'works' do
    visit loan_path(loan)
    click_link 'Change Amount or Terms'

    fill_in_valid_details

    expect {
      click_button 'Submit'
    }.to change(LoanChange, :count).by(1)

    verify

    current_path.should == loan_path(loan)
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Change Amount or Terms'
    click_button 'Submit'
    current_path.should == loan_loan_changes_path(loan)
  end

  private
    def fill_in(attribute, value)
      page.fill_in "loan_change_#{attribute}", with: value
    end

    def fill_in_valid_details
      fill_in 'date_of_change', '1/6/12'
      select ChangeType.find('1').name, from: 'loan_change_change_type_id'
      fill_in 'amount_drawn', '£15,000'
      fill_in 'business_name', 'updated'
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
