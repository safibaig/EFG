require 'spec_helper'
require 'importers'

describe RecoveryImporter do
  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, legacy_id: 143971) }
    let!(:loan2) { FactoryGirl.create(:loan, legacy_id: 160923) }
    let!(:user1) { FactoryGirl.create(:lender_user, username: 'user1') }
    let!(:user2) { FactoryGirl.create(:lender_user, username: 'user2') }

    before do
      RecoveryImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      RecoveryImporter.instance_variable_set(:@user_id_from_username, nil)
      RecoveryImporter.csv_path = Rails.root.join('spec/fixtures/import_data/SFLG_LOAN_RECOVERED_DATA_TABLE.csv')
      RecoveryImporter.import
    end

    it '0' do
      recovery = Recovery.first
      recovery.legacy_loan_id.should == '143971'
      recovery.loan.should == loan1
      recovery.seq.should == 1
      recovery.recovered_on.should == Date.new(2007, 5, 23)
      recovery.total_proceeds_recovered.should == Money.new(17_000_00)
      recovery.total_liabilities_after_demand.should == Money.new(120_000_56)
      recovery.total_liabilities_behind.should == Money.new(12_789_78)
      recovery.additional_break_costs.should == Money.new(1_000_00)
      recovery.additional_interest_accrued.should == Money.new(1_000_00)
      recovery.amount_due_to_dti.should == Money.new(12_825_00)
      recovery.realise_flag.should == true
      recovery.created_at.should == Date.new(2007, 5, 23)
      recovery.legacy_created_by.should == 'user1'
      recovery.created_by.should == user1
      recovery.ar_timestamp.should be_nil
      recovery.ar_insert_timestamp.should be_nil
      recovery.outstanding_non_efg_debt.should be_nil
      recovery.non_linked_security_proceeds.should be_nil
      recovery.linked_security_proceeds.should be_nil
      recovery.realisations_attributable.should be_nil
      recovery.realisations_due_to_gov.should be_nil
    end

    it '1' do
      recovery = Recovery.last
      recovery.legacy_loan_id.should == '160923'
      recovery.loan.should == loan2
      recovery.seq.should == 1
      recovery.recovered_on.should == Date.new(2009, 9, 22)
      recovery.total_proceeds_recovered.should == Money.new(80_000_00)
      recovery.total_liabilities_after_demand.should == Money.new(-1_00)
      recovery.total_liabilities_behind.should == Money.new(-1_00)
      recovery.additional_break_costs.should == Money.new(0)
      recovery.additional_interest_accrued.should == Money.new(0)
      recovery.amount_due_to_dti.should == Money.new(15_000_00)
      recovery.realise_flag.should == false
      recovery.created_at.should == Date.new(2009, 9, 23)
      recovery.legacy_created_by.should == 'user2'
      recovery.created_by.should == user2
      recovery.ar_timestamp.should be_nil
      recovery.ar_insert_timestamp.should be_nil
      recovery.outstanding_non_efg_debt.should == Money.new(10_000_00)
      recovery.non_linked_security_proceeds.should == Money.new(5_000_00)
      recovery.linked_security_proceeds.should == Money.new(20_000_00)
      recovery.realisations_attributable.should == Money.new(20_000_00)
      recovery.realisations_due_to_gov.should be_nil
    end
  end
end
