require 'spec_helper'
require 'importers'

describe InvoiceImporter do
  describe '.import' do
    let!(:lender1) { FactoryGirl.create(:lender, legacy_id: 11) }
    let!(:lender2) { FactoryGirl.create(:lender, legacy_id: 5) }
    let!(:user1) { FactoryGirl.create(:cfe_admin, username: 'a') }
    let!(:user2) { FactoryGirl.create(:cfe_admin, username: 'b') }

    before do
      InvoiceImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      InvoiceImporter.instance_variable_set(:@user_id_from_username, nil)
      InvoiceImporter.csv_path = Rails.root.join('spec/fixtures/import_data/invoices.csv')
      InvoiceImporter.import
    end

    it '0' do
      invoice = Invoice.all[0]
      invoice.lender.should == lender1
      invoice.legacy_id.should == 1
      invoice.version.should == 0
      invoice.reference.should == '980255-INV'
      invoice.xref.should == '980255-INV'
      invoice.period_covered_to_date.should == '30-SEP-06'
      invoice.period_covered_quarter.should == 'September'
      invoice.period_covered_year.should == '2006'
      invoice.received_on.should == Date.new(2006, 9, 25)
      invoice.created_by_legacy_id.should == 'a'
      invoice.created_by.should == user1
      invoice.creation_time.should == '27-SEP-06'
      invoice.ar_timestamp.should == '27-SEP-06'
      invoice.ar_insert_timestamp.should == '27-SEP-06'
    end

    it '1' do
      invoice = Invoice.all[1]
      invoice.lender.should == lender2
      invoice.legacy_id.should == 2
      invoice.version.should == 0
      invoice.reference.should == '872661-INV'
      invoice.xref.should == '872661-INV'
      invoice.period_covered_to_date.should == '31-MAR-06'
      invoice.period_covered_quarter.should == 'March'
      invoice.period_covered_year.should == '2006'
      invoice.received_on.should == Date.new(2006, 10, 5)
      invoice.created_by_legacy_id.should == 'b'
      invoice.created_by.should == user2
      invoice.creation_time.should == '09-OCT-06'
      invoice.ar_timestamp.should == '09-OCT-06'
      invoice.ar_insert_timestamp.should == '09-OCT-06'
    end
  end
end
