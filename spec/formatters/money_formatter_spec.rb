require 'spec_helper'

describe MoneyFormatter do
  describe '.format' do
    it 'returns a Money object' do
      MoneyFormatter.format(12345).should == Money.new(12345)
    end

    it 'does not return a zero-value Money object' do
      MoneyFormatter.format(nil).should be_nil
    end
  end

  describe '.parse' do
    it 'returns an integer of pence' do
      MoneyFormatter.parse('123.45').should == 12345
    end

    it 'returns nil for a blank value' do
      MoneyFormatter.parse('').should be_nil
    end
  end
end
