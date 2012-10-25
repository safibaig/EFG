require 'spec_helper'

describe PremiumMoney do

  describe "#initialize" do
    it "should round down half pennies" do
      PremiumMoney.new(10.1550).to_s.should == "10.15"
    end

    it "should round up if greater than half penny" do
      PremiumMoney.new(10.1555).to_s.should == "10.16"
    end
  end

end
