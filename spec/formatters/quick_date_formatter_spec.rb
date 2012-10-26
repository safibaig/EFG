require 'spec_helper'

describe QuickDateFormatter do
  describe '.parse' do
    it 'correctly parses dd/mm/yyyy' do
      QuickDateFormatter.parse('11/1/2011').should == Date.new(2011, 1, 11)
    end

    it 'correctly parses dd/mm/yy' do
      QuickDateFormatter.parse('11/1/11').should == Date.new(2011, 1, 11)
    end

    it 'allows a date from the 90s' do
      QuickDateFormatter.parse('3/2/1995').should == Date.new(1995, 2, 3)
    end

    it 'allows the date 1599' do
      QuickDateFormatter.parse('3/2/1599').should == Date.new(1599, 2, 3)
    end

    it 'does not blow up for a nil value' do
      QuickDateFormatter.parse(nil).should be_nil
    end

    it 'does not blow up for a blank value' do
      QuickDateFormatter.parse('').should be_nil
    end

    it 'does not blow up for an incorrectly formatted date' do
      QuickDateFormatter.parse('2008/01/01').should be_nil
    end

    it 'does not blow up when the wrong number of days/month is entered' do
      QuickDateFormatter.parse('31/9/2012').should be_nil
    end
  end
end
