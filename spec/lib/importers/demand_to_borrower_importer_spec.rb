require 'spec_helper'
require 'importers'

describe DemandToBorrowerImporter do
  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, legacy_id: 937) }
    let!(:loan2) { FactoryGirl.create(:loan, legacy_id: 995) }
    let!(:user1) { FactoryGirl.create(:user, username: 'qwerty') }
    let!(:user2) { FactoryGirl.create(:user, username: 'asdfgh') }

    before do
      DemandToBorrowerImporter.csv_path = Rails.root.join('spec/fixtures/import_data/demand_to_borrowers.csv')
      DemandToBorrowerImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      DemandToBorrowerImporter.instance_variable_set(:@user_id_from_username, nil)
    end

    def dispatch
      DemandToBorrowerImporter.import
    end

    it 'should import data correctly' do
      dispatch

      demand_to_borrower1 = DemandToBorrower.first!
      demand_to_borrower1.created_by.should == user1
      demand_to_borrower1.loan.should == loan1
      demand_to_borrower1.legacy_loan_id.should == 937
      demand_to_borrower1.seq.should == 1
      demand_to_borrower1.date_of_demand.should == Date.new(2007, 2, 11)
      demand_to_borrower1.demanded_amount.should == Money.new(10_000_00)
      demand_to_borrower1.modified_date.should == Date.new(2007, 2, 11)
      demand_to_borrower1.legacy_created_by.should == 'qwerty'
      demand_to_borrower1.ar_timestamp.should == nil
      demand_to_borrower1.ar_insert_timestamp.should == nil

      demand_to_borrower2 = DemandToBorrower.last!
      demand_to_borrower2.created_by.should == user2
      demand_to_borrower2.loan.should == loan2
      demand_to_borrower2.legacy_loan_id.should == 995
      demand_to_borrower2.seq.should == 3
      demand_to_borrower2.date_of_demand.should == Date.new(2007, 6, 4)
      demand_to_borrower2.demanded_amount.should == Money.new(25_000_00)
      demand_to_borrower2.modified_date.should == Date.new(2007, 6, 18)
      demand_to_borrower2.legacy_created_by.should == 'asdfgh'
      demand_to_borrower2.ar_timestamp.should == nil
      demand_to_borrower2.ar_insert_timestamp.should == nil
    end
  end
end
