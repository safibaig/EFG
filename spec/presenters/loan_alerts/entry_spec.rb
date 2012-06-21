require 'spec_helper'

describe LoanAlerts::Entry do

  let(:loan1) { FactoryGirl.create(:loan) }

  let(:loan2) { FactoryGirl.create(:loan) }

  let(:loan3) { FactoryGirl.create(:loan) }

  let(:entry) {
    loans = [ [loan1], [loan2], [loan3] ]
    LoanAlerts::Entry.new(loans, 4)
  }

  describe "#height" do
    it "should return a percentage height relative to the specified max loan count" do
      entry.height.should == 75
    end
  end

  describe "#count" do
    it "should return total number of loans for this entry" do
      entry.count.should == 3
    end
  end

end
