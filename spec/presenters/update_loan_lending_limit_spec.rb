require 'spec_helper'

describe UpdateLoanLendingLimit do
  describe "validations" do
    subject { FactoryGirl.build(:update_loan_lending_limit) }

    it "has a valid factory" do
      subject.should be_valid
    end

    it "requries a new_lending_limit_id" do
      subject.new_lending_limit_id = ''
      subject.should_not be_valid
    end
  end

  describe "#save" do
    let(:lender) { FactoryGirl.create(:lender) }
    let!(:lending_limit1) { FactoryGirl.create(:lending_limit, name: 'Lending Limit #1', lender: lender) }
    let!(:lending_limit2) { FactoryGirl.create(:lending_limit, name: 'Lending Limit #2', lender: lender, premium_rate: 10) }
    let!(:loan) { FactoryGirl.create(:loan, :completed, lender: lender, lending_limit: lending_limit1) }
    let!(:premium_schedule) { FactoryGirl.create(:premium_schedule, loan: loan) }
    let(:presenter) do
      UpdateLoanLendingLimit.new(loan).tap do |presenter|
        presenter.new_lending_limit_id = lending_limit2.id.to_s
      end
    end

    it "changes the lending limit on the loan" do
      presenter.new_lending_limit_id = lending_limit2.id.to_s
      presenter.save

      loan.reload
      loan.lending_limit.should == lending_limit2
    end

    it "stores the previous state aid figure" do
      previous_state_aid = loan.state_aid
      presenter.save

      presenter.previous_state_aid.should == previous_state_aid
    end

    it "stores the new state aid figure" do
      presenter.save

      presenter.new_state_aid.should == Money.new(246_446, 'EUR')
    end
  end
end
