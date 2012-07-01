require 'spec_helper'

describe MoneyFormatter.new do
  subject { MoneyFormatter.new }

  describe '.format' do
    it 'returns a Money object' do
      format(12345).should == Money.new(12345)
    end

    it 'does not return a zero-value Money object' do
      format(nil).should be_nil
    end
  end

  describe '.parse' do
    it 'returns an integer of pence' do
      parse('123.45').should == 12345
    end

    it 'returns nil for a blank value' do
      parse('').should be_nil
    end
  end
end
