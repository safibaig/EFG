require 'spec_helper'

describe LoanStateTransition do
  let(:klass) do
    Class.new do
      include LoanPresenter
      include LoanStateTransition

      transition from: [:a, :b], to: :c
    end
  end

  describe "must have LoanPresenter included" do
    it "should raise error" do
      expect {
        Class.new do
          include LoanStateTransition
        end
      }.to raise_error(RuntimeError)
    end
  end

  describe "#initialize" do
    it "should accept a loan in a correct from state" do
      loan = double(Loan, state: :b)

      expect {
        klass.new(loan)
      }.to_not raise_error(LoanStateTransition::IncorrectLoanState)
    end

    it 'is allowed to have a nil from state' do
      klass.transition({})
      loan = double(Loan, state: nil)

      expect {
        klass.new(loan)
      }.to_not raise_error(LoanStateTransition::IncorrectLoanState)
    end

    it "should raise an IncorrectLoanState error if the loan isn't in the from state" do
      loan = double(Loan, state: :z)

      expect {
        klass.new(loan)
      }.to raise_error(LoanStateTransition::IncorrectLoanState)
    end

    it "should initialize the loan" do
      loan = double(Loan, state: :a)
      presenter = klass.new(loan)
      presenter.loan.should == loan
    end
  end

  describe "#save" do
    it "should set the state to the to state" do
      save_result = mock
      loan = double(Loan, state: :a, save: save_result)
      loan.should_receive(:state=).with(:c)

      presenter = klass.new(loan)
      presenter.save.should == save_result
    end
  end
end
