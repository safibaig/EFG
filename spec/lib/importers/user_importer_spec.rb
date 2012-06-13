require 'spec_helper'
require 'importers'

describe UserImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/users.csv') }

  describe "#attributes" do
    let(:row) { CSV.read(csv_fixture_path, headers: true).first }
    let(:importer) { UserImporter.new(row, 100) }

    it "should return a hash of user attributes" do
      importer.attributes.should == {
        legacy_id: "B4B8938D980AD58C52B793D05466447CCDA92920",
        lender_id: "9",
        password: "PASSWORD",
        password_confirmation: "PASSWORD",
        created_at: "18-NOV-05",
        updated_at: "30-MAR-07",
        last_login_at: "18-JUN-07",
        version: "145",
        first_name: "FIRSTNAME",
        last_name: "LASTNAME",
        disabled: "0",
        memorable_name: "MEMORABLENAME",
        memorable_place: "MEMORABLEPLACE",
        memorable_year: "1900",
        login_failures: "0",
        password_changed_at: "30-MAR-07",
        locked: "0",
        ar_timestamp: "11-DEC-06",
        ar_insert_timestamp: "18-NOV-05",
        email: "user100@example.com",
        created_by: "59CEB98864F8236E81D0F45F4AAAB25352748C0D",
        confirm_t_and_c: "1",
        modified_by: "B4B8938D980AD58C52B793D05466447CCDA92920",
        knowledge_resource: "0"
      }
    end
  end

  describe ".import" do
    it "should create new user records" do
      expect {
        UserImporter.csv_path = csv_fixture_path
        UserImporter.import
      }.to change(User, :count).by(1)
    end
  end

end
