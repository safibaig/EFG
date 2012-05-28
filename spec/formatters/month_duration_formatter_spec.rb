require 'spec_helper'

describe MonthDurationFormatter do
  describe ".parse" do
    it "should convert the hash into the total number of months" do
      duration = MonthDurationFormatter.parse(years: 1, months: 11)
      duration.should == 23
    end

    it "should return nil with blank values" do
      MonthDurationFormatter.parse(years: '', months: '').should be_nil
    end
  end

  describe ".format" do
    it "should return nil if total_months is nil" do
      MonthDurationFormatter.format(nil).should be_nil
    end

    it 'should divide a number of months into years and months' do
      duration = MonthDurationFormatter.format(18)
      duration.years.should == 1
      duration.months.should == 6
      duration.total_months.should == 18
    end

    it "should handle 0" do
      duration = MonthDurationFormatter.format(0)
      duration.years.should == 0
      duration.months.should == 0
      duration.total_months.should == 0
    end
  end
end
