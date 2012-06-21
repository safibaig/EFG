require 'spec_helper'

describe LoanAlerts::Group do

  let(:loan1) { FactoryGirl.create(:loan) }

  let(:loan2) { FactoryGirl.create(:loan) }

  let(:loan3) { FactoryGirl.create(:loan) }

  let(:group) {
    loans = [ [loan1], [loan2], [loan3] ]
    LoanAlerts::Group.new(loans, :high, 1)
  }

  describe "#each_alert_by_day" do
    it "should yield a loan alerts entry for each day of loans" do
      group.each_alert_by_day do |yielded|
        yielded.should be_instance_of(LoanAlerts::Entry)
      end
    end
  end

  describe "#class_name" do
    it "should return a HTML class name string based on the priority of the group" do
      group.class_name.should == 'high-priority'
    end
  end

  describe "#total_loans" do
    it "should return the total number of loans in the group" do
      group.total_loans.should == 3
    end
  end


end
