require 'spec_helper'

describe LoanGuarantee do
  describe "validations" do
    let(:loan_guarantee) { FactoryGirl.build(:loan_guarantee) }

    it "should have a valid factory" do
      loan_guarantee.should be_valid
    end

    it "should be invalid if it hasn't received a declaration" do
      loan_guarantee.received_declaration = false
      loan_guarantee.should_not be_valid
    end

    it "should be invalid if they can't settle first premium" do
      loan_guarantee.first_pp_received = false
      loan_guarantee.should_not be_valid
    end

    it "should be invalid without a signed direct debit" do
      loan_guarantee.signed_direct_debit_received = false
      loan_guarantee.should_not be_valid
    end

    it "should be invalid without an initial draw date" do
      loan_guarantee.initial_draw_date = ''
      loan_guarantee.should_not be_valid
    end

    it "should be invalid without an initial draw value" do
      loan_guarantee.initial_draw_value = ''
      loan_guarantee.should_not be_valid
    end

    it "should should be invalid without a maturity date" do
      loan_guarantee.maturity_date = ''
      loan_guarantee.should_not be_valid
    end
  end
end
