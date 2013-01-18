require 'spec_helper'
require 'importers'

describe LoanModificationImporter do
  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loan_modifications.csv') }

  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, legacy_id: 5099) }
    let!(:loan2) { FactoryGirl.create(:loan, legacy_id: 1234) }
    let!(:user1) { FactoryGirl.create(:user, username: 'abc') }
    let!(:user2) { FactoryGirl.create(:user, username: 'xyz') }

    before do
      LoanModificationImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      LoanModificationImporter.instance_variable_set(:@user_id_from_username, nil)
      LoanModificationImporter.csv_path = csv_fixture_path
    end

    def dispatch
      LoanModificationImporter.import
    end

    let(:initial_draw_change) { LoanModification.all[0] }
    let(:loan_change) { LoanModification.all[1] }
    let(:data_correction) { LoanModification.all[2] }

    it 'imports InitialDrawChanges' do
      dispatch

      initial_draw_change.type.should == 'InitialDrawChange'
      initial_draw_change.loan.should == loan1
      initial_draw_change.created_by.should == user1
      initial_draw_change.oid.should == '5099'
      initial_draw_change.seq.should == 0
      initial_draw_change.date_of_change.should == Date.new(2006, 7, 28)
      initial_draw_change.maturity_date.should == nil
      initial_draw_change.old_maturity_date.should == nil
      initial_draw_change.business_name.should == nil
      initial_draw_change.old_business_name.should == nil
      initial_draw_change.lump_sum_repayment.should == nil
      initial_draw_change.amount_drawn.should == Money.new(200_000_00)
      initial_draw_change.modified_date.should == Date.new(2006, 8, 31)
      initial_draw_change.modified_user.should == 'abc'
      initial_draw_change.change_type_id.should == nil
      initial_draw_change.ar_timestamp.should == Date.new(2006, 8, 31)
      initial_draw_change.ar_insert_timestamp.should == Date.new(2006, 8, 31)
      initial_draw_change.amount.should == nil
      initial_draw_change.old_amount.should == nil
      initial_draw_change.facility_letter_date.should == nil
      initial_draw_change.old_facility_letter_date.should == nil
      initial_draw_change.initial_draw_date.should == nil
      initial_draw_change.old_initial_draw_date.should == nil
      initial_draw_change.initial_draw_amount.should == nil
      initial_draw_change.old_initial_draw_amount.should == nil
      initial_draw_change.sortcode.should == nil
      initial_draw_change.old_sortcode.should == nil
      initial_draw_change.dti_demand_out_amount.should == nil
      initial_draw_change.old_dti_demand_out_amount.should == nil
      initial_draw_change.dti_demand_interest.should == nil
      initial_draw_change.old_dti_demand_interest.should == nil
      initial_draw_change.lending_limit_id.should == nil
      initial_draw_change.old_lending_limit_id.should == nil
      initial_draw_change.loan_term.should == nil
      initial_draw_change.old_loan_term.should == nil
    end

    it 'imports LoanChanges' do
      dispatch

      loan_change.type.should == 'LoanChange'
      loan_change.loan.should == loan2
      loan_change.created_by.should == user1
      loan_change.oid.should == '1234'
      loan_change.seq.should == 1
      loan_change.date_of_change.should == Date.new(2006, 7, 29)
      loan_change.maturity_date.should == nil
      loan_change.old_maturity_date.should == nil
      loan_change.business_name.should == 'Foo'
      loan_change.old_business_name.should == 'Bar'
      loan_change.lump_sum_repayment.should == nil
      loan_change.amount_drawn.should == nil
      loan_change.modified_date.should == Date.new(2006, 8, 31)
      loan_change.modified_user.should == 'abc'
      loan_change.change_type_id.should == ChangeType::BusinessName.id
      loan_change.ar_timestamp.should == Date.new(2006, 8, 31)
      loan_change.ar_insert_timestamp.should == Date.new(2006, 8, 31)
      loan_change.amount.should == nil
      loan_change.old_amount.should == nil
      loan_change.facility_letter_date.should == nil
      loan_change.old_facility_letter_date.should == nil
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
      loan_change.lending_limit_id.should == nil
      loan_change.old_lending_limit_id.should == nil
      loan_change.loan_term.should == nil
      loan_change.old_loan_term.should == nil
    end

    it 'imports DataCorrections' do
      dispatch

      data_correction.type.should == 'DataCorrection'
      data_correction.loan.should == loan2
      data_correction.created_by.should == user2
      data_correction.oid.should == '1234'
      data_correction.seq.should == 2
      data_correction.date_of_change.should == Date.new(2006, 7, 30)
      data_correction.maturity_date.should == Date.new(2011, 11, 11)
      data_correction.old_maturity_date.should == Date.new(2012, 12, 12)
      data_correction.business_name.should == nil
      data_correction.old_business_name.should == nil
      data_correction.lump_sum_repayment.should == nil
      data_correction.amount_drawn.should == nil
      data_correction.modified_date.should == Date.new(2006, 8, 31)
      data_correction.modified_user.should == 'xyz'
      data_correction.change_type_id.should == ChangeType::DataCorrection.id
      data_correction.ar_timestamp.should == Date.new(2006, 8, 31)
      data_correction.ar_insert_timestamp.should == Date.new(2006, 8, 31)
      data_correction.amount.should == nil
      data_correction.old_amount.should == nil
      data_correction.facility_letter_date.should == nil
      data_correction.old_facility_letter_date.should == nil
      data_correction.initial_draw_date.should == nil
      data_correction.old_initial_draw_date.should == nil
      data_correction.initial_draw_amount.should == nil
      data_correction.old_initial_draw_amount.should == nil
      data_correction.sortcode.should == nil
      data_correction.old_sortcode.should == nil
      data_correction.dti_demand_out_amount.should == nil
      data_correction.old_dti_demand_out_amount.should == nil
      data_correction.dti_demand_interest.should == nil
      data_correction.old_dti_demand_interest.should == nil
      data_correction.lending_limit_id.should == nil
      data_correction.old_lending_limit_id.should == nil
      data_correction.loan_term.should == nil
      data_correction.old_loan_term.should == nil
    end
  end
end
