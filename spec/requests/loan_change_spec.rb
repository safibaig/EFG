# encoding: utf-8

require 'spec_helper'

describe 'loan change' do
  let(:loan) {
    FactoryGirl.create(:loan, :guaranteed,
      maturity_date: Date.new(2014, 12, 25),
      repayment_duration: 60
    ).tap { |loan|
      loan.initial_draw_change.update_column(:date_of_change, Date.new(2009, 12, 25))
    }
  }

  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }

  context 'lump_sum_repayment' do
    before do
      visit_loan_changes
      click_link 'Lump Sum Repayment'
    end

    it 'works' do
      fill_in :date_of_change, '1/6/12'
      fill_in :lump_sum_repayment, '1234.56'
      click_button 'Submit'

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::LumpSumRepayment
      loan_change.date_of_change.should == Date.new(2012, 6, 1)
      loan_change.lump_sum_repayment.should == Money.new(1_234_56)

      loan.reload
      loan.modified_by.should == current_user
    end
  end

  context 'repayment_duration' do
    before do
      visit_loan_changes
      click_link 'Extend / Reduce'
    end

    it 'works' do
      fill_in :date_of_change, '1/6/12'
      fill_in :added_months, '3'
      click_button 'Submit'

      loan_change = loan.loan_changes.last!
      loan_change.change_type.should == ChangeType::ExtendTerm
      loan_change.date_of_change.should == Date.new(2012, 6, 1)
      loan_change.repayment_duration.should == 63

      loan.reload
      loan.modified_by.should == current_user
      loan.repayment_duration.total_months.should == 63
      loan.maturity_date.should == Date.new(2015, 3, 25)
    end
  end

  private
    def fill_in(attribute, value)
      page.fill_in "loan_change_#{attribute}", with: value
    end

    def visit_loan_changes
      visit loan_path(loan)
      click_link 'Change Amount or Terms'
    end
end
