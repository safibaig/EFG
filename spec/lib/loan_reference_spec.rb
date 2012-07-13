require 'spec_helper'

describe LoanReference do

  describe "#initialize" do
    it "raises exception when invalid reference" do
      %w(wrong 1111111 A1B2C3D ABC123-01 ABC123+01 ABC12345+04 ABC1234+100).each do |string|
        expect {
          LoanReference.new(string)
        }.to raise_error(InvalidLoanReference)
      end
    end

    it "does not raise exception when valid reference" do
      %w(ABC1234+01 ABC1234-01).each do |string|
        expect {
          LoanReference.new(string)
        }.to_not raise_error(InvalidLoanReference)
      end
    end
  end

  it 'possible reference characters and numbers, before version number, do not include 1, 0, I or O' do
    %w(1 0 I O).each do |char|
      LoanReference::LETTERS_AND_NUMBERS.should_not include(char)
    end
  end

  describe '#generate' do
    let(:loan) { FactoryGirl.build(:loan) }

    it "should return reference in format {letters/numbers}{separator}{version number}" do
      reference = LoanReference.generate

      reference[0,6].should match(/\d*[A-Z]*/)
      reference[-3,3].should match(/\+\d{2}/)
    end

    it "should not end in E+{numbers}" do
      LoanReference.stub(:random_string).and_return('AABBCCE', 'DDEEFFE', 'ABCDEFG')

      LoanReference.generate.should == 'ABCDEFG+01'
    end
  end

  describe "#increment" do
    let(:loan_reference) { LoanReference.new('ABCDEFG+01') }

    it "should return incremented loan reference" do
      loan_reference.increment.should == 'ABCDEFG+02'
    end

    it "should increment loan reference into double digits" do
      loan_reference = LoanReference.new('ABCDEFG+09')

      loan_reference.increment.should == 'ABCDEFG+10'
    end

    it "should not increment loan reference repeatedly" do
      reference = nil

      2.times { reference = loan_reference.increment }

      reference.should == 'ABCDEFG+02'
    end
  end

end