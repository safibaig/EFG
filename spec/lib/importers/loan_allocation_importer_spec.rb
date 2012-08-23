require 'spec_helper'
require 'importers'

describe LoanAllocationImporter do

  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 260) }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loan_allocations.csv') }

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
      loan_allocation.starts_on == Date.new(2007, 4, 1)
      loan_allocation.ends_on == Date.new(2008, 3, 31)
      loan_allocation.description == "DESCRIPTION"
      loan_allocation.modified_by_legacy_id == "4D726727C893A0437B9D2724C6E678CDDBB88AED"
      loan_allocation.updated_at == Time.gm(2009, 5, 13)
      loan_allocation.ar_timestamp == Time.gm(2010, 3, 28)
      loan_allocation.ar_insert_timestamp == Time.gm(2010, 3, 31)
      loan_allocation.premium_rate == "2"
      loan_allocation.guarantee_rate == "75"
    end

    it "should associate user with lender" do
      dispatch

      LoanAllocation.last.lender.should == lender
    end
  end

end
