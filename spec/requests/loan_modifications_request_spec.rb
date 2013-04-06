# encoding: utf-8

require 'spec_helper'

describe 'LoanModifications' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  before { login_as(current_user, scope: :user) }

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender, repayment_duration: 60) }

  before do
    FactoryGirl.create(:loan_change, loan: loan, change_type: ChangeType::ExtendTerm, repayment_duration: 63, old_repayment_duration: 60)
    FactoryGirl.create(:data_correction, loan: loan, sortcode: '654321', old_sortcode: '123456')
    FactoryGirl.create(:loan_change, loan: loan, change_type: ChangeType::LumpSumRepayment, lump_sum_repayment: Money.new(1_234_56))
  end

  describe 'index' do
    before do
      visit loan_path(loan)
      click_link 'Loan Changes'
    end

    it 'includes all LoanModifications' do
      page.all('table tbody tr').length.should == 4

      page.should have_content('Initial draw and guarantee')
      page.should have_content('Extend term')
      page.should have_content('Data correction')
      page.should have_content('Lump sum repayment')
    end
  end

  describe 'show' do
    before do
      loan.initial_draw_change.amount_drawn = Money.new(5_000_00)
      loan.initial_draw_change.save!

      visit loan_path(loan)
    end

    it 'includes the amount drawn for an InitialDrawChange' do
      click_link 'Loan Changes'
      click_link 'Initial draw and guarantee'

      page.should have_content('£5,000.00')
    end

    it 'includes new and old values for a LoanChange' do
      click_link 'Loan Changes'
      click_link 'Extend term'

      page.should have_content('60')
      page.should have_content('63')
    end

    it 'includes LoanChange#lump_sum_repayment' do
      click_link 'Loan Changes'
      click_link 'Lump sum repayment'

      page.should have_content('£1,234.56')
    end

    it 'includes new and old values for a DataCorrection' do
      click_link 'Loan Changes'
      click_link 'Data correction'

      page.should have_content('654321')
      page.should have_content('123456')
    end

    it 'includes new and old values for a LendingLimit DataCorrection' do
      old_lending_limit = loan.lending_limit
      lending_limit = FactoryGirl.create(:lending_limit, lender: loan.lender, name: 'new lending limit')
      FactoryGirl.create(:data_correction, loan: loan, old_lending_limit_id: old_lending_limit.id, lending_limit_id: lending_limit.id)

      click_link 'Loan Changes'
      page.all('table tbody a').first.click

      page.should have_content(old_lending_limit.name)
      page.should have_content('new lending limit')
    end
  end
end
