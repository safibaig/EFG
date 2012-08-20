require 'spec_helper'
require 'importers'

describe LoanRealisationImporter do
  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, legacy_id: 2087) }
    let!(:loan2) { FactoryGirl.create(:loan, legacy_id: 2207) }
    let!(:user1) { FactoryGirl.create(:lender_user, username: 'a') }
    let!(:user2) { FactoryGirl.create(:lender_user, username: 'b') }

    before do
      LoanRealisationImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      LoanRealisationImporter.instance_variable_set(:@user_id_from_username, nil)
      LoanRealisationImporter.csv_path = Rails.root.join('spec/fixtures/import_data/loan_realisations.csv')
      LoanRealisationImporter.import
    end

    it '0' do
      loan_realisation = LoanRealisation.first
      loan_realisation.legacy_loan_id.should == 2087
      loan_realisation.realised_loan.should == loan1
      loan_realisation.legacy_created_by.should == 'a'
      loan_realisation.created_by.should == user1
      loan_realisation.realised_amount.should == Money.new(3_753_76)
      loan_realisation.realised_on.should == Date.new(2001, 7, 20)
      loan_realisation.seq.should == '1'
      loan_realisation.created_at.should == Date.new(2007, 4, 18)
      loan_realisation.ar_timestamp.should == '1'
      loan_realisation.ar_insert_timestamp.should == '2'
    end

    it '1' do
      loan_realisation = LoanRealisation.last
      loan_realisation.legacy_loan_id.should == 2207
      loan_realisation.realised_loan.should == loan2
      loan_realisation.legacy_created_by.should == 'b'
      loan_realisation.created_by.should == user2
      loan_realisation.realised_amount.should == Money.new(21_945_92)
      loan_realisation.realised_on.should == Date.new(1997, 3, 11)
      loan_realisation.seq.should == '1'
      loan_realisation.created_at.should == Date.new(2007, 4, 18)
      loan_realisation.ar_timestamp.should == '1'
      loan_realisation.ar_insert_timestamp.should == '2'
    end
  end
end
