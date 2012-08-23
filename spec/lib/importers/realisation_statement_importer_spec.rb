require 'spec_helper'
require 'importers'

describe RealisationStatementImporter do
  describe '.import' do
    let!(:lender1) { FactoryGirl.create(:lender, legacy_id: 11) }
    let!(:lender2) { FactoryGirl.create(:lender, legacy_id: 260) }
    let!(:loan1) { FactoryGirl.create(:loan, legacy_id: 143, lender: lender1) }
    let!(:loan2) { FactoryGirl.create(:loan, legacy_id: 156, lender: lender2) }
    let!(:user1) { FactoryGirl.create(:lender_user, username: 'user1') }
    let!(:user2) { FactoryGirl.create(:lender_user, username: 'user2') }

    before do
      RealisationStatementImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      RealisationStatementImporter.instance_variable_set(:@user_id_from_username, nil)
      RealisationStatementImporter.csv_path = Rails.root.join('spec/fixtures/import_data/SFLG_RECOVERY_STATEMENT_DATA_TABLE.csv')
      RealisationStatementImporter.import
    end

    it '0' do
      realisation_statement = RealisationStatement.first
      realisation_statement.reference.should == 'Q3 2011'
      realisation_statement.period_covered_to_date.should == Date.new(2011, 9, 30)
      realisation_statement.period_covered_quarter.should == 'September'
      realisation_statement.period_covered_year.should == '2011'
      realisation_statement.received_on.should == Date.new(2011, 10, 4)
      realisation_statement.created_at.should == Date.new(2011, 10, 19)
      realisation_statement.version.should == '0'
      realisation_statement.legacy_id.should == '143'
      realisation_statement.legacy_lender_id.should == '11'
      realisation_statement.lender.should == lender1
      realisation_statement.legacy_created_by.should == 'user1'
      realisation_statement.created_by.should == user1
      realisation_statement.ar_timestamp.should be_nil
      realisation_statement.ar_insert_timestamp.should be_nil
    end

    it '1' do
      realisation_statement = RealisationStatement.last
      realisation_statement.reference.should == 'Q1 2012'
      realisation_statement.period_covered_to_date.should == Date.new(2012, 3, 31)
      realisation_statement.period_covered_quarter.should == 'March'
      realisation_statement.period_covered_year.should == '2012'
      realisation_statement.received_on.should == Date.new(2012, 4, 10)
      realisation_statement.created_at.should == Date.new(2012, 4, 10)
      realisation_statement.version.should == '0'
      realisation_statement.legacy_id.should == '156'
      realisation_statement.legacy_lender_id.should == '260'
      realisation_statement.lender.should == lender2
      realisation_statement.legacy_created_by.should == 'user2'
      realisation_statement.created_by.should == user2
      realisation_statement.ar_timestamp.should be_nil
      realisation_statement.ar_insert_timestamp.should be_nil
    end
  end
end
