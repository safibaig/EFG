require 'spec_helper'

describe LenderLendingLimit do
  describe "#initialize" do
    let(:lender) { FactoryGirl.build(:lender) }

    it "is initialized with a lender" do
      LenderLendingLimit.new(lender)
    end
  end

  describe "validations" do
    let(:lender) { FactoryGirl.build(:lender) }
    subject { LenderLendingLimit.new(lender) }

    it "should be valid with valid attributes" do
      subject.allocation = 213
      subject.should be_valid
    end

    it "should be invalid without an allocation" do
      subject.should_not be_valid
    end
  end

  describe "#selected?" do
    let(:lender) { FactoryGirl.build(:lender) }
    subject { LenderLendingLimit.new(lender) }

    describe 'deselected by default' do
      it { should_not be_selected }
    end

    describe 'after being selected' do
      before { subject.selected = true }

      it { should be_selected }
    end
  end

  describe "delegating to the lender" do
    let(:lender) { double(Lender, id: 1, name: 'name', to_key: 'key') }

    subject { LenderLendingLimit.new(lender) }

    its(:id) { should == 1 }
    its(:name) { should == 'name' }
    its(:to_key) { should == 'key' }
  end

  describe "#allocation" do
    let(:lender) { double(Lender, id: 1, name: 'name') }
    let(:lender_lending_limit) { LenderLendingLimit.new(lender) }

    before { lender_lending_limit.allocation = '123.45' }

    subject { lender_lending_limit.allocation }

    it { should == Money.new(12345) }
  end
end
