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

  describe ".from_params" do
    it "should convert the hash into a MonthDuration" do
      duration = MonthDuration.from_params(years: 1, months: 11)
      duration.years.should == 1
      duration.months.should == 11
      duration.total_months.should == 23
    end

    it "should handle blank values" do
      duration = MonthDuration.from_params(years: '', months: '')
      duration.years.should == 0
      duration.months.should == 0
      duration.total_months.should == 0
    end
  end

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
end
