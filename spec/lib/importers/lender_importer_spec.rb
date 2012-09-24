require 'spec_helper'
require 'importers'

describe LenderImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/lenders.csv') }

  describe ".import" do
    def dispatch
      LenderImporter.instance_variable_set(:@organisation_reference_codes, nil)
      LenderImporter.csv_path = csv_fixture_path
      LenderImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(Lender, :count).by(3)
    end

    it "should import data correctly" do
      dispatch

      lender = Lender.first
      lender.legacy_id.should == 465
      lender.name.should == "ACME"
      lender.created_at.should == Time.gm(2010, 4, 1)
      lender.updated_at.should == Time.gm(2010, 5, 11)
      lender.version = 1
      lender.high_volume.should == true
      lender.can_use_add_cap.should == true
      lender.organisation_reference_code.should == "LC"
      lender.primary_contact_name.should == "PRIMARY CONTACT NAME"
      lender.primary_contact_phone.should == "01010101010101010101"
      lender.primary_contact_email.should == "emailaddress@emailaddress.emailaddress"
      lender.std_cap_lending_allocation.should == 123
      lender.add_cap_lending_allocation.should == 456
      lender.should_not be_disabled
      lender.ar_timestamp.should == Time.gm(2006, 12, 11)
      lender.ar_insert_timestamp.should == Time.gm(2007, 3, 20)
      lender.created_by_legacy_id.should == 'B0A11CFA070A9EB86882BB5199645F1232C47F8E'
      lender.modified_by_legacy_id.should == '8CD950DED80063E4502DDAD23C4A0D7EF03B7EE3'
      lender.allow_alert_process.should == true
      lender.main_point_of_contact_user.should == "CC0312A05920C0BC0204CB65162AD1B9F5C94033"
      lender.loan_scheme.should == "E"
    end

    it "should ensure organisation reference code is unique" do
      dispatch

      lenders = Lender.all
      lenders[0].organisation_reference_code.should == "LC"
      lenders[1].organisation_reference_code.should == "LC2"
      lenders[2].organisation_reference_code.should == "LC3"
    end

  end

end
