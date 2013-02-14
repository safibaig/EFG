# encoding: utf-8

require 'spec_helper'

describe 'state aid calculations' do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }

  before do
    login_as(current_user, scope: :user)
    navigate_to_state_aid_calculation_page
  end

  describe 'creating' do
    let(:loan) {
      FactoryGirl.create(:loan, :eligible,
                         lender: current_lender,
                         amount: '123456',
                         repayment_duration: { months: 12 })
    }

    it 'pre-fills some fields' do
      page.find('#state_aid_calculation_repayment_duration').value.should == '12'
    end

    it 'creates a new record with valid data' do
      fill_in :initial_draw_amount, '£123,456'
      fill_in :initial_capital_repayment_holiday, '0'
      fill_in :second_draw_amount, '£0'
      fill_in :second_draw_months, '£0'

      expect {
        click_button 'Submit'
      }.to change(StateAidCalculation, :count).by(1)

      current_path.should == new_loan_entry_path(loan)

      state_aid_calculation = StateAidCalculation.last
      state_aid_calculation.loan.should == loan
      state_aid_calculation.initial_draw_amount.should == Money.new(123_456_00)
      state_aid_calculation.repayment_duration.should == 12
      state_aid_calculation.initial_capital_repayment_holiday.should == 0
      state_aid_calculation.second_draw_amount.should == 0
      state_aid_calculation.second_draw_months.should == 0
      state_aid_calculation.third_draw_amount.should be_nil
      state_aid_calculation.third_draw_months.should be_nil
      state_aid_calculation.fourth_draw_amount.should be_nil
      state_aid_calculation.fourth_draw_months.should be_nil
    end
  end

  describe 'updating an existing state_aid_calculation' do
    let(:loan) {
      FactoryGirl.create(:loan, :eligible,
                         lender: current_lender,
                         repayment_duration: { months: 60 },
                         amount: Money.new(100_000_00))
    }
    let!(:state_aid_calculation) {
      FactoryGirl.create(:state_aid_calculation,
                         repayment_duration: 120,
                         loan: loan)
    }

    it 'updates the record' do
      fill_in :initial_draw_amount, '£80,000'
      fill_in :second_draw_amount, '£20,000'
      fill_in :second_draw_months, '10'
      click_button 'Submit'

      current_path.should == new_loan_entry_path(loan)

      state_aid_calculation.reload
      state_aid_calculation.initial_draw_amount.should == Money.new(80_000_00)
      state_aid_calculation.second_draw_amount.should == Money.new(20_000_00)
    end

    it 'does not update the record with invalid data' do
      fill_in :initial_draw_amount, ''
      click_button 'Submit'

      current_path.should == loan_state_aid_calculation_path(loan)

      state_aid_calculation.reload.initial_draw_amount.should_not be_nil
    end

    it 'pulls the repayment duration from the loan' do
      page.find('#state_aid_calculation_repayment_duration').value.should == '60'

      click_button 'Submit'

      state_aid_calculation.reload
      state_aid_calculation.repayment_duration.should == 60
    end
  end

  private
    def navigate_to_state_aid_calculation_page
      visit loan_path(loan)
      click_link 'Loan Entry'
      click_button 'State Aid Calculation'
    end

    def fill_in(attribute, value)
      page.fill_in "state_aid_calculation_#{attribute}", with: value
    end
end
