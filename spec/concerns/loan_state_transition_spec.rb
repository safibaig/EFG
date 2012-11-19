require 'spec_helper'

describe LoanStateTransition do
  let(:klass) do
    Class.new do
      def self.name
        'MockLoanPresenter'
      end

      include LoanPresenter
      include LoanStateTransition

      transition from: [Loan::AutoCancelled, Loan::AutoRemoved], to: Loan::Offered, event: :complete
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
      loan = double(Loan, state: Loan::AutoCancelled)

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
      loan = double(Loan, id: 40, state: :z)

      expect {
        klass.new(loan)
      }.to raise_error(LoanStateTransition::IncorrectLoanState, "MockLoanPresenter tried to transition Loan:40 with state:z")
    end
  end

  describe "#save" do
    let(:loan) { FactoryGirl.build(:loan, :auto_removed) }
    let(:user) { FactoryGirl.create(:user) }

    it "should change the state of the loan" do
      presenter = klass.new(loan)
      presenter.save

      loan.state.should == Loan::Offered
    end
  end
end
