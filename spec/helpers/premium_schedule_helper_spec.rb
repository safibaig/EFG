require 'spec_helper'

describe PremiumScheduleHelper do
  describe "premiums_table_rows" do
    it "with an even number of premiums" do
      premiums = [Money.new(10000), Money.new(70000), Money.new(40000), Money.new(35000)]
      premiums_table_rows(premiums).to_a.should == [
        [[1, Money.new(10000)], [3, Money.new(40000)]],
        [[2, Money.new(70000)], [4, Money.new(35000)]],
      ]
    end

    it "with an odd number of premiums" do
      premiums = [Money.new(10000), Money.new(70000), Money.new(40000)]
      premiums_table_rows(premiums).to_a.should == [
        [[1, Money.new(10000)], [3, Money.new(40000)]],
        [[2, Money.new(70000)], nil],
      ]
    end
  end
end
