require 'spec_helper'

describe MonthDuration do
  describe '#==' do
    it 'is true when the total_months are the same' do
      MonthDuration.new(30).should == MonthDuration.new(30)
    end

    it 'is false when the total_months are not the same' do
      MonthDuration.new(30).should_not == MonthDuration.new(29)
    end
  end

  describe '#format' do
    it '1 month' do
      MonthDuration.new(1).format.should == '1 month'
    end

    it 'many months' do
      MonthDuration.new(11).format.should == '11 months'
    end

    it '1 year' do
      MonthDuration.new(12).format.should == '1 year'
    end

    it 'many years' do
      MonthDuration.new(36).format.should == '3 years'
    end

    it '1 year and 1 month' do
      MonthDuration.new(13).format.should == '1 year, 1 month'
    end

    it '1 year and many months' do
      MonthDuration.new(15).format.should == '1 year, 3 months'
    end

    it 'many years and 1 month' do
      MonthDuration.new(37).format.should == '3 years, 1 month'
    end

    it 'many years and many month' do
      MonthDuration.new(47).format.should == '3 years, 11 months'
    end
  end

  describe "comparable" do
    it "should have correct < behaviour" do
      (MonthDuration.new(3) < MonthDuration.new(4)).should be_true
    end

    it "should have correct > behaviour" do
      (MonthDuration.new(10) > MonthDuration.new(4)).should be_true
    end

    it "should have the correct between? behaviour" do
      MonthDuration.new(2).should_not be_between(MonthDuration.new(3), MonthDuration.new(5))
      MonthDuration.new(3).should be_between(MonthDuration.new(3), MonthDuration.new(5))
      MonthDuration.new(4).should be_between(MonthDuration.new(3), MonthDuration.new(5))
      MonthDuration.new(5).should be_between(MonthDuration.new(3), MonthDuration.new(5))
      MonthDuration.new(6).should_not be_between(MonthDuration.new(3), MonthDuration.new(5))
    end
  end
end
