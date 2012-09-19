require 'spec_helper'
require 'importers'

describe UserAuditImporter do

  let!(:user1) { FactoryGirl.create(:user, username: "wald5654r") }

  let!(:user2) { FactoryGirl.create(:user, username: "scar6628c") }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_USER_AUDIT_DATA_TABLE.csv') }

  describe ".import" do
    before do
      UserAuditImporter.instance_variable_set(:@user_id_from_username, nil)
      UserAuditImporter.csv_path = csv_fixture_path
    end

    def dispatch
      UserAuditImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(UserAudit, :count).by(2)
    end

    it "should import data correctly" do
      dispatch

      user_audit1 = UserAudit.first
      user_audit1.user.should == user1
      user_audit1.version.should == 1
      user_audit1.updated_at.should == Time.gm(2010, 5, 11)
      user_audit1.modified_by.should == user2
      user_audit1.password.should == 'GlcTxloQerJNfzPl9jxyL/CIaYU='
      user_audit1.function.should == 'Password generated'
      user_audit1.ar_timestamp.should == Time.gm(2006, 10, 28)
      user_audit1.ar_insert_timestamp.should == Time.gm(2006, 10, 27)

      user_audit2 = UserAudit.last
      user_audit2.user.should == user2
      user_audit2.version.should == 2
      user_audit2.updated_at.should == Time.gm(2011, 6, 20)
      user_audit2.modified_by.should == user1
      user_audit2.password.should == '1J6l/H5ziTZlKTMpLL/HnNWmQWE='
      user_audit2.function.should == 'Initial login'
      user_audit2.ar_timestamp.should == Time.gm(2008, 8, 16)
      user_audit2.ar_insert_timestamp.should == Time.gm(2008, 8, 15)
    end
  end

end
