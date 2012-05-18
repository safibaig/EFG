require 'spec_helper'

describe MonthDuration do
  describe '.new' do
    it 'should divide a number of months into years and months' do
      duration = MonthDuration.new(18)
      duration.years.should == 1
      duration.months.should == 6
      duration.total_months.should == 18
    end

    it 'should handle nil' do
      duration = MonthDuration.new(nil)
      duration.years.should == 0
      duration.months.should == 0
      duration.total_months.should == 0
    end

    it "should handle 0" do
      duration = MonthDuration.new(0)
      duration.years.should == 0
      duration.months.should == 0
      duration.total_months.should == 0
    end
  end

  describe ".from_hash" do
    it "should convert the hash into a MonthDuration" do
      duration = MonthDuration.from_hash(years: 1, months: 11)
      duration.years.should == 1
      duration.months.should == 11
      duration.total_months.should == 23
    end

    it "should handle blank values" do
      duration = MonthDuration.from_hash(years: '', months: '')
      duration.years.should == 0
      duration.months.should == 0
      duration.total_months.should == 0
    end
  end
end
