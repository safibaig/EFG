require 'spec_helper'

describe Invoice do
  describe "validations" do
    let(:invoice) { FactoryGirl.build(:invoice) }

    it "should have a valid factory" do
      invoice.should be_valid
    end

    it "must have a lender" do
      invoice.lender = nil
      invoice.should_not be_valid
    end

    it "must have a reference" do
      invoice.reference = ''
      invoice.should_not be_valid
    end

    it "must have a period covered quarter" do
      invoice.period_covered_quarter = ''
      invoice.should_not be_valid
    end

    it "must have a valid period covered quarter" do
      invoice.period_covered_quarter = 'August'
      invoice.should_not be_valid
    end

    it "must have a period covered year" do
      invoice.period_covered_year = ''
      invoice.should_not be_valid
    end

    it "must have a valid period covered year" do
      invoice.period_covered_year = '01'
      invoice.should_not be_valid
    end

    it "must have a received on date" do
      invoice.received_on = ''
      invoice.should_not be_valid
    end

    it "must have a valid received on date" do
      invoice.received_on = '2012-06-05'
      invoice.should_not be_valid
    end

    it "must have a creator" do
      invoice.created_by = nil
      invoice.should_not be_valid
    end

    it "must have some loans" do
      invoice.settled_loan_ids = []
      invoice.should_not be_valid
    end
  end
end
