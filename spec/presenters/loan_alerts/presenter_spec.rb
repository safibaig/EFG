require 'spec_helper'

describe LoanAlerts::Presenter do

  let(:high_priority_loan) { FactoryGirl.create(:loan, updated_at: 52.days.ago) }

  let(:medium_priority_loan) { FactoryGirl.create(:loan, updated_at: 42.days.ago) }

  let(:low_priority_loan) { FactoryGirl.create(:loan, updated_at: 5.days.ago) }

  let(:presenter) {
    priority_group = double('PriorityGroup',
      high_priority_loans: [ [high_priority_loan] ],
      medium_priority_loans: [ [medium_priority_loan] ],
      low_priority_loans: [ [low_priority_loan] ]
    )
    LoanAlerts::Presenter.new(priority_group)
  }

  describe "#alerts_grouped_by_priority" do
    it "should create high priority, medium priority and low priority loan alert groups" do
      LoanAlerts::Group.should_receive(:new).exactly(3).times

      presenter.alerts_grouped_by_priority
    end

    it "should return an array of loan alert groups" do
      result = presenter.alerts_grouped_by_priority

      result.should be_instance_of(Array)
      result.each { |r| r.should be_instance_of(LoanAlerts::Group) }
    end
  end

end
