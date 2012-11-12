require 'spec_helper'

include LoanAlerts

describe LoanAlerts::CombinedLoanAlert do
  let(:alert1) { double('LoanAlert', start_date: Date.new(2012, 11, 12), end_date: Date.new(2012, 12, 12), date_method: :updated_at) }
  let(:alert2) { double('LoanAlert', start_date: Date.new(2012, 11,  5), end_date: Date.new(2012, 12,  5), date_method: :updated_at) }
  let(:combined) { CombinedLoanAlert.new(alert1, alert2) }

  describe ".new" do
    it "raises an ArgumentError if the alert's date_methods don't match" do
      alert1 = double('LoanAlert', date_method: :updated_at)
      alert2 = double('LoanAlert', date_method: :maturity_date)

      expect {
        CombinedLoanAlert.new(alert1, alert2)
      }.to raise_error(ArgumentError, 'alerts must have matching date_method')
    end
  end

  describe "#start_date" do
    it "returns the earliest of the two start_dates" do
      combined.start_date.should == Date.new(2012, 11, 5)
    end
  end

  describe "#end_date" do
    it "returns the latest of the two end_dates" do
      combined.end_date.should == Date.new(2012, 12, 12)
    end
  end

  describe "#date_method" do
    it "returns the date_method for the two alerts" do
      combined.date_method.should == :updated_at
    end
  end

  describe "#loans" do
    it "fetches the loans from both alerts, and sorts by the date method" do
      loan1 = double('Loan 1', updated_at: Date.new(2012, 10, 1))
      loan2 = double('Loan 2', updated_at: Date.new(2012, 10, 20))
      loan3 = double('Loan 3', updated_at: Date.new(2012, 11, 1))
      loan4 = double('Loan 4', updated_at: Date.new(2012, 11, 20))
      loan5 = double('Loan 5', updated_at: Date.new(2012, 12, 1))
      loan6 = double('Loan 6', updated_at: Date.new(2012, 12, 20))

      alert1 = double('LoanAlert', loans: [loan1, loan3, loan5], date_method: :updated_at)
      alert2 = double('LoanAlert', loans: [loan2, loan4, loan6], date_method: :updated_at)
      combined = CombinedLoanAlert.new(alert1, alert2)

      combined.loans.should == [loan1, loan2, loan3, loan4, loan5, loan6]
    end
  end
end
