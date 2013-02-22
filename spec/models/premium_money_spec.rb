require 'spec_helper'

describe PremiumMoney do

  describe "#initialize" do
    it "should round down half pennies" do
      PremiumMoney.new(BigDecimal.new('1015.50')).to_s.should == "10.15"
    end

    it "should round up if greater than half penny" do
      PremiumMoney.new(BigDecimal.new('1015.50001')).to_s.should == "10.16"
    end
  end

end
