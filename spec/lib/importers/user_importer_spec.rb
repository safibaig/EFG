require 'spec_helper'
require 'importers'

describe UserImporter do

  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 9) }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/users.csv') }

  let(:user_roles_csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/user_roles.csv') }

  describe ".import" do
    before do
      UserImporter.csv_path = csv_fixture_path
      UserRoleMapper.user_roles_csv_path = user_roles_csv_fixture_path
      UserImporter.instance_variable_set(:@already_imported_emails, [])
      UserImporter.instance_variable_set(:@user_id_from_username, nil)
    end

    def dispatch
      UserImporter.import
    end

    it "should create new user records" do
      expect {
        dispatch
      }.to change(User, :count).by(6)
    end

    it "should import data correctly" do
      dispatch

      user = User.find_by_username('ahan8063s')
      user.username.should == "ahan8063s"
      user.legacy_lender_id.should == 9
      user.encrypted_password.should be_blank
      user.created_at.should == Time.gm(2005, 11, 18)
      user.updated_at.should_not be_blank
      user.last_sign_in_at.should == Time.gm(2007, 6, 18)
      user.version.should == 145
      user.first_name.should == "Joe"
      user.last_name.should == "Bloggs"
      user.should_not be_disabled
      user.memorable_name.should == "MEMORABLENAME"
      user.memorable_place.should == "MEMORABLEPLACE"
      user.memorable_year.should == "1900"
      user.login_failures.should == 0
      user.password_changed_at.should == Time.gm(2007, 3, 30)
      user.should be_locked
      user.ar_timestamp.should == Time.gm(2006, 12, 11)
      user.ar_insert_timestamp.should == Time.gm(2005, 11, 18)
      user.email.should == 'joe@example.com'
      user.created_by_legacy_id.should == "will8561s"
      user.modified_by_legacy_id.should == "thom5918r"
      user.confirm_t_and_c.should == true
      user.knowledge_resource.should == false
    end

    it "should associate lender user with lender" do
      dispatch

      User.find_by_username('ahan8063s').lender.should == lender
    end

    it "should associate user with user who created record" do
      dispatch

      User.find_by_username('ahan8063s').created_by.should == User.find_by_username('will8561s')
    end

    it "should associate user with user who last modified the record" do
      dispatch

      user = User.find_by_username('ahan8063s')
      user.modified_by.should == User.find_by_username('thom5918r')
    end

    it "should assign correct user type for LenderUser" do
      dispatch

      user = User.find_by_username('ahan8063s')
      user.type.should == "LenderUser"
      user.lender_id.should be_present
    end

    it "should assign correct user type for LenderAdmin" do
      dispatch

      user = User.find_by_username('will8561s')
      user.type.should == "LenderAdmin"
      user.lender_id.should be_present
    end

    it "should disable users who are not LenderAdmin or LenderUser" do
      dispatch

      User.find_all_by_username(%w(thom5918r jaya6359d jack1234e mull5432n)).each do |user|
        user.should be_disabled
      end
    end

    it "should assign correct user type for CfeAdmin users" do
      dispatch

      user = User.find_by_username('thom5918r')
      user.type.should == "CfeAdmin"
      user.lender_id.should be_nil
    end

    it "should assign correct user type for PremiumCollectorUser users" do
      dispatch

      user = User.find_by_username('jaya6359d')
      user.type.should == "PremiumCollectorUser"
      user.lender_id.should be_nil
    end

    it "should assign correct user type for AuditorUser users" do
      dispatch

      user = User.find_by_username('jack1234e')
      user.type.should == "AuditorUser"
      user.lender_id.should be_nil
    end

    it "should assign correct user type for CfeUser users" do
      dispatch

      user = User.find_by_username('mull5432n')
      user.type.should == "CfeUser"
      user.lender_id.should be_nil
    end
  end

end
