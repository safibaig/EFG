require 'spec_helper'

describe LoanStateTransition do
  let(:klass) do
    Class.new do
      include LoanStateTransition

      attribute :name
    end
  end

  let(:loan) { double(Loan) }
  let(:transition) { klass.new(loan) }

  describe "#initialize" do
    it "should take a loan" do
      transition = klass.new(loan)
      transition.loan.should == loan
    end
  end

  describe "attribute delegation" do
    it "should delegate the reader to the loan" do
      loan.should_receive(:name).and_return('Name')

      transition.name.should == 'Name'
    end

    it "should delegate the writer to the loan" do
      loan.should_receive(:name=).with('NewName')

      transition.name = 'NewName'
    end
  end
end
