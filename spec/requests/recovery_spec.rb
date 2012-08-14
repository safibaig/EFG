# encoding: utf-8

require 'spec_helper'

describe 'loan recovery' do
  let(:loan) { FactoryGirl.create(:loan, :settled, amount_demanded: '123', dti_amount_claimed: '456', settled_on: '1/5/12') }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  [Loan::Settled, Loan::Recovered, Loan::Realised].each do |state|
    context "with state #{state}" do
      let(:loan) { FactoryGirl.create(:loan, state.to_sym, amount_demanded: '123', dti_amount_claimed: '456', settled_on: '1/5/12') }

      it 'creates a loan recovery' do
        visit loan_path(loan)
        click_link 'Recovery Made'
        page.should_not have_button('Submit')

        expect {
          fill_in_valid_details
          click_button 'Calculate'

          page.should have_content('£1,500.00')
          page.should have_content('£1,125.00')
        }.not_to change(Recovery, :count)

        expect {
          click_button 'Submit'
        }.to change(Recovery, :count).by(1)

        verify_recovery_and_loan

        current_path.should == loan_path(loan)
      end
    end
  end

  it 'does not continue with invalid values' do
    visit loan_path(loan)
    click_link 'Recovery Made'

    expect {
      fill_in_valid_details
      click_button 'Calculate'
    }.not_to change(Recovery, :count)

    expect {
      fill_in_invalid_details
      click_button 'Submit'
    }.not_to change(Recovery, :count)

    current_path.should == loan_recoveries_path(loan)
  end

  private
    def fill_in(attribute, value)
      page.fill_in "recovery_#{attribute}", with: value
    end

    def fill_in_valid_details
      fill_in 'recovered_on', '1/6/12'
      fill_in 'outstanding_non_efg_debt', '£2500.00'
      fill_in 'non_linked_security_proceeds', '£3000.00'
      fill_in 'linked_security_proceeds', '£1000.00'
    end

    def fill_in_invalid_details
      fill_in 'recovered_on', ''
      fill_in 'outstanding_non_efg_debt', ''
      fill_in 'non_linked_security_proceeds', ''
      fill_in 'linked_security_proceeds', ''
    end

    def verify_recovery_and_loan
      recovery = Recovery.last
      recovery.recovered_on.should == Date.new(2012, 6, 1)
      recovery.outstanding_non_efg_debt.should == Money.new(2_500_00)
      recovery.non_linked_security_proceeds.should == Money.new(3_000_00)
      recovery.linked_security_proceeds.should == Money.new(1_000_00)
      recovery.realisations_attributable.should == Money.new(1_500_00)
      recovery.amount_due_to_dti.should == Money.new(1_125_00)

      loan.reload
      loan.state.should == Loan::Recovered
      loan.recovery_on.should == Date.new(2012, 6, 1)
      loan.modified_by.should == current_user
    end
end
