require 'spec_helper'

describe PhaseWithLendingLimits do
  describe "validations" do

    let(:phase_with_lending_limits) { FactoryGirl.build(:phase_with_lending_limits) }

    it "should have a valid factory" do
      phase_with_lending_limits.should be_valid
    end

    it "should be invalid without a name" do
      phase_with_lending_limits.name = ''
      phase_with_lending_limits.should_not be_valid
    end
  end

  describe "#lenders" do
    let(:phase_with_lending_limits) { PhaseWithLendingLimits.new }
    let(:lender) { double(Lender) }

    before { Lender.stub!(:order_by_name).and_return([lender]) }

    subject { phase_with_lending_limits.lenders }

    it "should use the order_by_name scope on Lenders" do
      Lender.should_receive(:order_by_name)
      subject
    end

    its(:first) { should be_kind_of(LenderLendingLimit) }
  end
end
