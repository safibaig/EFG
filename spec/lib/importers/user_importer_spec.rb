require 'spec_helper'
require 'importers'

describe UserImporter do

  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 9) }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/users.csv') }

  describe ".import" do
    before do
      UserImporter.csv_path = csv_fixture_path
    end

    def dispatch
      UserImporter.import
    end

    it "should create new user records" do
      expect {
        dispatch
      }.to change(User, :count).by(1)
    end

    it "should import data correctly" do
      dispatch

      user = User.last
      user.legacy_id.should == "B4B8938D980AD58C52B793D05466447CCDA92920"
      user.legacy_lender_id.should == 9
      user.encrypted_password.should_not be_blank
      user.created_at.should == Time.gm(2005, 11, 18)
      user.updated_at.should_not be_blank
      user.last_sign_in_at.should == Time.gm(2007, 6, 18)
      user.version.should == 145
      user.first_name.should == "FIRSTNAME"
      user.last_name.should == "LASTNAME"
      user.should_not be_disabled
      user.memorable_name.should == "MEMORABLENAME"
      user.memorable_place.should == "MEMORABLEPLACE"
      user.memorable_year.should == "1900"
      user.login_failures.should == 0
      user.password_changed_at.should == Time.gm(2007, 3, 30)
      user.should_not be_locked
      user.ar_timestamp.should == Time.gm(2006, 12, 11)
      user.ar_insert_timestamp.should == Time.gm(2005, 11, 18)
      user.email.should be_nil
      user.created_by_legacy_id.should == "59CEB98864F8236E81D0F45F4AAAB25352748C0D"
      user.modified_by_legacy_id.should == "B4B8938D980AD58C52B793D05466447CCDA92920"
      user.confirm_t_and_c.should == true
      user.knowledge_resource.should == false
    end

    it "should associate user with lender" do
      dispatch

      User.last.lender.should == lender
    end

    it "should associate user with user who created record" do
      creation_user = FactoryGirl.create(:user, legacy_id: "59CEB98864F8236E81D0F45F4AAAB25352748C0D")

      dispatch

      User.last.created_by.should == creation_user
    end

    it "should associate user with user who last modified the record" do
      dispatch

      user = User.last
      user.modified_by.should == user
    end
  end

end
