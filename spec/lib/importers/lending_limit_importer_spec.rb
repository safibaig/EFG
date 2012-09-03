require 'spec_helper'
require 'importers'

describe LendingLimitImporter do
  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 260) }
  let!(:user1) { FactoryGirl.create(:lender_admin, username: 'user1') }

  describe ".import" do
    before do
      LendingLimitImporter.csv_path = Rails.root.join('spec/fixtures/import_data/lending_limits.csv')
      LendingLimitImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      LendingLimitImporter.instance_variable_set(:@user_id_from_username, nil)
    end

    def dispatch
      LendingLimitImporter.import
    end

    it do
      expect {
        dispatch
      }.to change(LendingLimit, :count).by(1)
    end

    it "should import data correctly" do
      dispatch

      lending_limit = LendingLimit.last
      lending_limit.legacy_id == "646"
      lending_limit.lender_legacy_id == "3"
      lending_limit.lender.should == lender
      lending_limit.version == "1"
      lending_limit.allocation_type_id == "1"
      lending_limit.active == "0"
      lending_limit.allocation == Money.parse("500000")
      lending_limit.starts_on == Date.new(2007, 4, 1)
      lending_limit.ends_on == Date.new(2008, 3, 31)
      lending_limit.name == "DESCRIPTION"
      lending_limit.modified_by_legacy_id == "user1"
      lending_limit.modified_by.should == user1
      lending_limit.updated_at == Time.gm(2009, 5, 13)
      lending_limit.ar_timestamp == Time.gm(2010, 3, 28)
      lending_limit.ar_insert_timestamp == Time.gm(2010, 3, 31)
      lending_limit.premium_rate == "2"
      lending_limit.guarantee_rate == "75"
    end
  end
end
