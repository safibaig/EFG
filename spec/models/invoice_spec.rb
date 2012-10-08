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
      invoice.loans_to_be_settled_ids = []
      invoice.should_not be_valid
    end
  end

  describe "#xref" do
    let(:invoice) { FactoryGirl.build(:invoice) }

    it "should be set on creation" do
      invoice.xref.should be_blank
      invoice.save!
      invoice.xref.should_not be_blank
    end

    it "should be unique" do
      invoice.save!

      another_invoice = FactoryGirl.build(:invoice)
      another_invoice.stub!(:random_xref).and_return(invoice.xref, '789012-INV')

      another_invoice.save!
      another_invoice.xref.should == '789012-INV'
    end

    it "should have 6 random numbers followed by '-INV'" do
      invoice.save!
      invoice.xref.should match(/\d{6}-INV/)
    end
  end
end
