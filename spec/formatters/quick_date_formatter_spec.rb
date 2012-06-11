require 'spec_helper'

describe QuickDateFormatter do
  describe '.parse' do
    it 'correctly parses dd/mm/yyyy' do
      QuickDateFormatter.parse('11/1/2011').should == Date.new(2011, 1, 11)
    end

    it 'correctly parses dd/mm/yy' do
      QuickDateFormatter.parse('11/1/11').should == Date.new(2011, 1, 11)
    end

    it 'does not blow up for a nil value' do
      QuickDateFormatter.parse(nil).should be_nil
    end

    it 'does not blow up for a blank value' do
      QuickDateFormatter.parse('').should be_nil
    end
  end
end
