require 'spec_helper'
require 'importers'

describe LoanAllocationImporter do
  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 260) }
  let!(:user1) { FactoryGirl.create(:lender_admin, username: 'user1') }

  describe ".import" do
    before do
      LoanAllocationImporter.csv_path = Rails.root.join('spec/fixtures/import_data/loan_allocations.csv')
      LoanAllocationImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      LoanAllocationImporter.instance_variable_set(:@user_id_from_username, nil)
    end

    def dispatch
      LoanAllocationImporter.import
    end

    it "should create new loan allocation record" do
      expect {
        dispatch
      }.to change(LoanAllocation, :count).by(1)
    end

    it "should import data correctly" do
      dispatch

      loan_allocation = LoanAllocation.last
      loan_allocation.legacy_id == "646"
      loan_allocation.lender_legacy_id == "3"
      loan_allocation.lender.should == lender
      loan_allocation.version == "1"
      loan_allocation.allocation_type == "1"
      loan_allocation.active == "0"
      loan_allocation.allocation == Money.parse("500000")
      loan_allocation.starts_on == Date.new(2007, 4, 1)
      loan_allocation.ends_on == Date.new(2008, 3, 31)
      loan_allocation.description == "DESCRIPTION"
      loan_allocation.modified_by_legacy_id == "user1"
      loan_allocation.modified_by.should == user1
      loan_allocation.updated_at == Time.gm(2009, 5, 13)
      loan_allocation.ar_timestamp == Time.gm(2010, 3, 28)
      loan_allocation.ar_insert_timestamp == Time.gm(2010, 3, 31)
      loan_allocation.premium_rate == "2"
      loan_allocation.guarantee_rate == "75"
    end
  end
end
