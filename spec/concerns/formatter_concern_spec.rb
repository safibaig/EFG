require 'spec_helper'

describe FormatterConcern do
  module Formatter
    def self.format; end
    def self.parse; end
  end

  let(:klass) {
    Class.new do
      include FormatterConcern

      format :foo, with: Formatter
    end
  }
  let(:instance) { klass.new }

  describe 'reading' do
    it 'passes through the formatter and returns' do
      value = double
      formatted = double
      instance.should_receive(:read_attribute).with(:foo).and_return(value)
      Formatter.should_receive(:format).with(value).and_return(formatted)
      instance.foo.should == formatted
    end
  end

  describe 'writing' do
    it 'passes through the formatter and writes' do
      value = double
      formatted = double
      Formatter.should_receive(:parse).with(value).and_return(formatted)
      instance.should_receive(:write_attribute).with(:foo, formatted)
      instance.foo = value
    end
  end
end
