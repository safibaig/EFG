require 'spec_helper'

describe LoanAlerts::PriorityGrouping do

  describe '.merge' do

    let(:group1) {
      double(LoanAlerts::PriorityGrouping,
        high_priority_loans: [[1], [2], [3]],
        medium_priority_loans: [[4], [5], [6]],
        low_priority_loans: [[7], [8], [9], [10]]
      )
    }

    let(:group2) {
      double(LoanAlerts::PriorityGrouping,
        high_priority_loans: [[11], [12], [13]],
        medium_priority_loans: [[14], [15], [16]],
        low_priority_loans: [[17], [18], [19]]
      )
    }

    it "returns a PriorityGrouping with merge high, medium, low loans" do
      merged_grouping = LoanAlerts::PriorityGrouping.merge(group1, group2)
      merged_grouping.high_priority_loans.should == [[1, 11], [2, 12], [3, 13]]
      merged_grouping.medium_priority_loans.should == [[4, 14], [5, 15], [6, 16]]
      merged_grouping.low_priority_loans.should == [[7, 17], [8, 18], [9, 19], [10]]
    end
  end

  describe ".for_alert" do
    it "instantiates a PriorityGrouping from a LoanAlert" do
      loans = double('alert loans')
      start_date = Date.new(2012, 11, 8)
      end_date = Date.new(2013, 5, 8)
      date_method = :updated_at
      alert = double(LoanAlerts::LoanAlert, loans: loans, start_date: start_date, end_date: end_date, date_method: date_method)
      alert_class = double('LoanAlert class')
      alert_class.stub(:new).and_return(alert)

      lender = double(Lender)

      priority_grouping = double(LoanAlerts::PriorityGrouping)
      LoanAlerts::PriorityGrouping.should_receive(:new).with(loans, start_date, end_date, date_method).and_return(priority_grouping)

      LoanAlerts::PriorityGrouping.for_alert(alert_class, lender).should == priority_grouping
    end
  end

  describe "grouping loans" do
    let(:date) { Date.parse("31-10-2012") }

    let!(:high_priority_loan1) { FactoryGirl.create(:loan, :offered, maturity_date: 59.weekdays_ago(date)) }

    let!(:high_priority_loan2) { FactoryGirl.create(:loan, :offered, maturity_date: 50.weekdays_ago(date)) }

    let!(:medium_priority_loan1) { FactoryGirl.create(:loan, :offered, maturity_date: 49.weekdays_ago(date)) }

    let!(:medium_priority_loan2) { FactoryGirl.create(:loan, :offered, maturity_date: 30.weekdays_ago(date)) }

    let!(:low_priority_loan1) { FactoryGirl.create(:loan, :offered, maturity_date: 29.weekdays_ago(date)) }

    let!(:low_priority_loan2) { FactoryGirl.create(:loan, :offered, maturity_date: date) }

    let(:priority_grouping) {
      loans_array = [
        high_priority_loan1,
        high_priority_loan2,
        medium_priority_loan1,
        medium_priority_loan2,
        low_priority_loan1,
        low_priority_loan2
      ]
      LoanAlerts::PriorityGrouping.new(loans_array, 59.weekdays_ago(date).to_date, date, :maturity_date)
    }

    describe "#high_priority_loans" do
      it "returns all high priority loans" do
        priority_grouping.high_priority_loans.should == padded_array_of_arrays(10, {
          0 => [high_priority_loan1],
          9 => [high_priority_loan2]
        })
      end
    end

    describe "#medium_priority_loans" do
      it "returns all medium priority loans" do
        priority_grouping.medium_priority_loans.should == padded_array_of_arrays(20, {
          0 => [medium_priority_loan1],
          19 => [medium_priority_loan2]
        })
      end
    end

    describe "#low_priority_loans" do
      it "returns all low priority loans" do
        priority_grouping.low_priority_loans.should == padded_array_of_arrays(30, {
          0 => [low_priority_loan1],
          29 => [low_priority_loan2]
        })
      end
    end
  end

  private

  # Returns an Array of +length+ padded with empty Array's. Uses the +contents+
  # hash to populate the array at the specified indexes.
  def padded_array_of_arrays(length, contents)
    Array.new(length) { |index| contents[index] || [] }
  end

end
