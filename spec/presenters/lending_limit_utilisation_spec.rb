require 'spec_helper'

describe LendingLimitUtilisation do

  let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }

  let(:lending_limit) { lender.lending_limits.first }

  let!(:loan1) {
    FactoryGirl.create(
      :loan,
      :guaranteed,
      lender: lender,
      lending_limit: lending_limit,
      amount: 250000
    )
  }

  let!(:loan2) {
    FactoryGirl.create(
      :loan,
      :guaranteed,
      lender: lender,
      lending_limit: lending_limit,
      amount: 50000
    )
  }

  let(:presenter) { LendingLimitUtilisation.new(lending_limit) }

  let(:presenter_with_no_loans) {
    lending_limit.loans.clear
    LendingLimitUtilisation.new(lending_limit)
  }

  describe "#chart_colour" do
    it "should return green when allocation usage is 50%" do
      presenter.stub!(:usage_percentage).and_return(50.0)
      presenter.chart_colour.should == "#00c000"
    end

    it "should return green when allocation usage is less than 50%" do
      presenter.stub!(:usage_percentage).and_return(43.0)
      presenter.chart_colour.should == "#00c000"
    end

    it "should return yellow when allocation usage is greater than 50% and less than 85%" do
      presenter.stub!(:usage_percentage).and_return(60.0)
      presenter.chart_colour.should == "#FF7E00"
    end

    it "should return yellow when allocation usage is 85%" do
      presenter.stub!(:usage_percentage).and_return(85.0)
      presenter.chart_colour.should == "#FF7E00"
    end

    it "should return red when allocation usage is greater 85%" do
      presenter.stub!(:usage_percentage).and_return(90.0)
      presenter.chart_colour.should == "#ff0000"
    end
  end

  describe "#usage_amount" do
    it "should return sum of all loan amounts" do
      presenter.usage_amount.should == loan1.amount + loan2.amount
    end

    it "should return 0 when allocation has no loans" do
      presenter_with_no_loans.usage_amount.should == Money.new(0)
    end
  end

  describe "#usage_percentage" do
    it "should return percentage of total allocation used" do
      presenter.usage_percentage.should == "30.00"
    end

    it "should return 0 when allocation has no loans" do
      presenter_with_no_loans.usage_percentage.should == 0
    end
  end

end
