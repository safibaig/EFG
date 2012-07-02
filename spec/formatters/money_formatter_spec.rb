require 'spec_helper'

describe MoneyFormatter.new do
  subject { MoneyFormatter.new }

  describe '.format' do
    it 'returns a Money object' do
      subject.format(12345).should == Money.new(12345)
    end

    it 'does not return a zero-value Money object' do
      subject.format(nil).should be_nil
    end
  end

  describe '.parse' do
    it 'returns an integer of pence' do
      subject.parse('123.45').should == 12345
    end

    it 'returns nil for a blank value' do
      subject.parse('').should be_nil
    end
  end
end
