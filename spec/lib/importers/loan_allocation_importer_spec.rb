require 'spec_helper'
require 'importers'

describe LoanAllocationImporter do

  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 260) }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loan_allocations.csv') }

  describe "#attributes" do
    let(:row) { CSV.read(csv_fixture_path, headers: true).first }
    let(:importer) { LoanAllocationImporter.new(row) }

    it "should return a hash of attributes" do
      importer.attributes.should == {
        legacy_id: "646",
        lender_legacy_id: "260",
        lender_id: lender.id,
        version: "1",
        allocation_type: "1",
        active: "0",
        allocation: 50000000,
        starts_on: "01-APR-07",
        ends_on: "31-MAR-08",
        description: "DESCRIPTION",
        modified_by_legacy_id: "4D726727C893A0437B9D2724C6E678CDDBB88AED",
        updated_at: "13-MAY-09",
        ar_timestamp: "28-MAR-10",
        ar_insert_timestamp: "31-MAR-10",
        premium_rate: "2",
        guarantee_rate: "75"
      }
    end
  end

  describe ".import" do
    def dispatch
      LoanAllocationImporter.csv_path = csv_fixture_path
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
      loan_allocation.version == "1"
      loan_allocation.allocation_type == "1"
      loan_allocation.active == "0"
      loan_allocation.allocation == Money.parse("500000")
      loan_allocation.starts_on == "01-APR-07"
      loan_allocation.ends_on == "31-MAR-08"
      loan_allocation.description == "DESCRIPTION"
      loan_allocation.modified_by_legacy_id == "4D726727C893A0437B9D2724C6E678CDDBB88AED"
      loan_allocation.updated_at == "13-MAY-09"
      loan_allocation.ar_timestamp == "28-MAR-10"
      loan_allocation.ar_insert_timestamp == "31-MAR-10"
      loan_allocation.premium_rate == "2"
      loan_allocation.guarantee_rate == "75"
    end

    it "should associate user with lender" do
      dispatch

      LoanAllocation.last.lender.should == lender
    end
  end

end
