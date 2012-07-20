require 'spec_helper'
require 'importers'

describe LoanChangeImporter do
  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loan_changes.csv') }

  describe '.import' do
    let!(:loan) { FactoryGirl.create(:loan, legacy_id: 5099) }
    let!(:user) { FactoryGirl.create(:user, legacy_id: '51BB5F278B5F9ABCF695A5C8F1C9D75A1E482C8A') }

    before do
      LoanChangeImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      LoanChangeImporter.instance_variable_set(:@user_id_from_modified_user, nil)
      LoanChangeImporter.csv_path = csv_fixture_path
    end

    def dispatch
      LoanChangeImporter.import
    end

    it 'should create new user records' do
      expect {
        dispatch
      }.to change(LoanChange, :count).by(1)
    end

    it 'should import data correctly' do
      dispatch

      loan_change = LoanChange.last
      loan_change.oid.should == '5099'
      loan_change.seq.should == 0
      loan_change.date_of_change.should == Date.new(2006, 7, 28)
      loan_change.maturity_date.should == nil
      loan_change.old_maturity_date.should == nil
      loan_change.business_name.should == nil
      loan_change.old_business_name.should == nil
      loan_change.lump_sum_repayment.should == nil
      loan_change.amount_drawn.should == Money.new(200_000_00)
      loan_change.modified_date.should == Date.new(2006, 8, 31)
      loan_change.modified_user.should == '51BB5F278B5F9ABCF695A5C8F1C9D75A1E482C8A'
      loan_change.change_type.should == nil
      loan_change.ar_timestamp.should == Date.new(2006, 8, 31)
      loan_change.ar_insert_timestamp.should == Date.new(2006, 8, 31)
      loan_change.amount.should == nil
      loan_change.old_amount.should == nil
      loan_change.guaranteed_date.should == nil
      loan_change.old_guaranteed_date.should == nil
      loan_change.initial_draw_date.should == nil
      loan_change.old_initial_draw_date.should == nil
      loan_change.initial_draw_amount.should == nil
      loan_change.old_initial_draw_amount.should == nil
      loan_change.sortcode.should == nil
      loan_change.old_sortcode.should == nil
      loan_change.dti_demand_out_amount.should == nil
      loan_change.old_dti_demand_out_amount.should == nil
      loan_change.dti_demand_interest.should == nil
      loan_change.old_dti_demand_interest.should == nil
      loan_change.cap_id.should == nil
      loan_change.old_cap_id.should == nil
      loan_change.loan_term.should == nil
      loan_change.old_loan_term.should == nil
    end

    it do
      dispatch
      LoanChange.last.loan.should == loan
    end

    it do
      dispatch
      LoanChange.last.created_by.should == user
    end
  end
end
