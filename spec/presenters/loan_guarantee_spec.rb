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

    it "should be invalid without an initial_draw_amount" do
      loan_guarantee.initial_draw_amount = ''
      loan_guarantee.should_not be_valid
    end

    it "should should be invalid without a maturity date" do
      loan_guarantee.maturity_date = ''
      loan_guarantee.should_not be_valid
    end
  end

  describe '#save' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }
    let(:loan) { loan_guarantee.loan }
    let(:loan_guarantee) {
      FactoryGirl.build(:loan_guarantee,
        initial_draw_amount: Money.new(5_000_00),
        initial_draw_date: '1/1/11',
        modified_by: lender_user
      )
    }

    it 'creates an initial loan_change' do
      loan_guarantee.save.should == true

      loan.loan_changes.count.should == 1

      initial_change = loan.loan_changes.first!
      initial_change.amount_drawn.should == Money.new(5_000_00)
      initial_change.change_type_id.should == nil
      initial_change.created_by.should == lender_user
      initial_change.date_of_change.should == Date.new(2011)
      initial_change.modified_date.should == Date.current
      initial_change.seq.should == 0
    end
  end
end
