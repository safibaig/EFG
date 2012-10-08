require 'spec_helper'

describe TransferredLoanEntry do

  describe "#initialize" do
    let(:loan) { FactoryGirl.build(:loan, :incomplete) }

    it 'raises exception when loan is not a transferred loan' do
      expect {
        TransferredLoanEntry.new(loan)
      }.to raise_error(ArgumentError)
    end
  end

  describe "validations" do
    let(:transferred_loan_entry) { FactoryGirl.build(:transferred_loan_entry) }

    it "should have a valid factory" do
      transferred_loan_entry.should be_valid
    end

    it "should be invalid if the declaration hasn't been signed" do
      transferred_loan_entry.declaration_signed = false
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a amount" do
      transferred_loan_entry.amount = ''
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment duration" do
      transferred_loan_entry.repayment_duration = ''
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment frequency" do
      transferred_loan_entry.repayment_frequency_id = nil
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a maturity date" do
      transferred_loan_entry.maturity_date = nil
      transferred_loan_entry.should_not be_valid
    end

    it "should be invalid without a state aid calculation" do
      transferred_loan_entry.loan.state_aid_calculations.delete_all
      transferred_loan_entry.should_not be_valid
      transferred_loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    context 'maturity_date' do
      let(:initial_draw_date) { transferred_loan_entry.loan.initial_draw_change.date_of_change }

      it "must be on or after the minimum number of loan repayment months, counted from the original draw date" do
        transferred_loan_entry.maturity_date = initial_draw_date + (3.months - 1.day)
        transferred_loan_entry.should_not be_valid

        transferred_loan_entry.maturity_date = initial_draw_date + 3.months
        transferred_loan_entry.should be_valid
      end

      it "must be on or before the maximum number of loan repayment months, counted from the original draw date" do
        transferred_loan_entry.maturity_date = initial_draw_date + (120.months + 1.day)
        transferred_loan_entry.should_not be_valid

        transferred_loan_entry.maturity_date = initial_draw_date + 120.months
        transferred_loan_entry.should be_valid
      end
    end
  end
end
