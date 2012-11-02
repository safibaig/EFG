require 'spec_helper'

describe LoanAlerts::PriorityGrouping do

  describe '.merge_groups' do

    let(:group1) {
      {
        high_priority: [ [1],[2],[3] ],
        medium_priority: [ [4],[5],[6] ],
        low_priority: [ [7],[8],[9],[10] ]
      }
    }

    let(:group2) {
      {
        high_priority: [[11],[12],[13]],
        medium_priority: [[14],[15],[16]],
        low_priority: [[17],[18],[19]]
      }
    }

    it "should return a hash of merged arrays" do
      expected_hash = {
        high_priority: [ [1,11], [2,12], [3,13] ],
        medium_priority: [ [4,14],[5,15],[6,16] ],
        low_priority: [ [7,17],[8,18],[9,19],[10] ]
      }

      LoanAlerts::PriorityGrouping.merge_groups(group1, group2).should == expected_hash
    end
  end

  describe "#groups_hash" do
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

    it "should return hash of loan arrays grouped by high priority, medium priority and low priority, skipping weekends" do
      priority_grouping.groups_hash[:high_priority].should == padded_array_of_arrays(10, {
        0 => [high_priority_loan1],
        9 => [high_priority_loan2]
      })

      priority_grouping.groups_hash[:medium_priority].should == padded_array_of_arrays(20, {
        0 => [medium_priority_loan1],
        19 => [medium_priority_loan2]
      })

      priority_grouping.groups_hash[:low_priority].should == padded_array_of_arrays(30, {
        0 => [low_priority_loan1],
        29 => [low_priority_loan2]
      })
    end
  end

  private

  def padded_array_of_arrays(length, arrays_to_inject_hash)
    array = []
    length.times do |num|
      if arrays_to_inject_hash[num]
        array << arrays_to_inject_hash[num]
      else
        array << []
      end
    end
    array
  end

end
