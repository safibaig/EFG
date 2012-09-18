# encoding: utf-8

require 'spec_helper'

describe LoanDemandToBorrower do
  describe 'validations' do
    let(:loan_demand_to_borrower) { FactoryGirl.build(:loan_demand_to_borrower) }

    it 'should have a valid factory' do
      loan_demand_to_borrower.should be_valid
    end

    it 'should be invalid without a borrower demanded date' do
      loan_demand_to_borrower.borrower_demanded_on = ''
      loan_demand_to_borrower.should_not be_valid
    end

    it 'should be invalid without amount_demanded' do
      loan_demand_to_borrower.amount_demanded = ''
      loan_demand_to_borrower.should_not be_valid
    end
  end

  describe '#save' do
    let(:loan_demand_to_borrower) {
      FactoryGirl.build(:loan_demand_to_borrower,
        amount_demanded: '£1,000',
        borrower_demanded_on: '5/6/07'
      )
    }
    let(:loan) { loan_demand_to_borrower.loan }

    before do
      loan.save!
    end

    it 'creates a corresponding DemandToBorrower' do
      expect {
        loan_demand_to_borrower.save.should == true
      }.to change(DemandToBorrower, :count).by(1)

      demand_to_borrower = DemandToBorrower.last!
      demand_to_borrower.loan.should == loan
      demand_to_borrower.date_of_demand.should == Date.new(2007, 6, 5)
      demand_to_borrower.demanded_amount.should == Money.new(1_000_00)
    end
  end
end
