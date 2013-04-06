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

    it "should be invalid when initial draw date is before facility letter date" do
      loan_guarantee.initial_draw_date = loan_guarantee.loan.facility_letter_date - 1.day
      loan_guarantee.should_not be_valid

      loan_guarantee.initial_draw_date = loan_guarantee.loan.facility_letter_date
      loan_guarantee.should be_valid
    end

    it "should be invalid when initial draw date is more than 6 months after facility letter date" do
      loan_guarantee.initial_draw_date = loan_guarantee.loan.facility_letter_date.advance(months: 6, days: 1)
      loan_guarantee.should_not be_valid

      loan_guarantee.initial_draw_date = loan_guarantee.loan.facility_letter_date.advance(months: 6)
      loan_guarantee.should be_valid
    end
  end

  describe '#save' do
    let(:lender_user) { FactoryGirl.create(:lender_user) }
    let(:premium_schedule) { FactoryGirl.build(:premium_schedule, initial_draw_amount: Money.new(5_000_00)) }
    let(:loan) { FactoryGirl.create(:loan, :offered, premium_schedules: [premium_schedule], amount: Money.new(5_000_00)) }
    let(:loan_guarantee) do
      LoanGuarantee.new(loan).tap do |loan_guarantee|
        loan_guarantee.attributes = FactoryGirl.attributes_for(:loan_guarantee)
        loan_guarantee.modified_by = lender_user
      end
    end

    it 'creates an InitialDrawChange' do
      loan_guarantee.save.should == true

      initial_draw_change = loan.initial_draw_change
      initial_draw_change.amount_drawn.should == Money.new(5_000_00)
      initial_draw_change.change_type.should == nil
      initial_draw_change.created_by.should == lender_user
      initial_draw_change.date_of_change.should == Date.current
      initial_draw_change.modified_date.should == Date.current
      initial_draw_change.seq.should == 0
    end

    it 'creates a LoanStateChange' do
      expect {
        loan_guarantee.save.should == true
      }.to change(LoanStateChange, :count).by(1)

      state_change = loan.state_changes.last
      state_change.event_id.should == 7
      state_change.state.should == Loan::Guaranteed
    end

    it "updates the maturity date to the initial draw date + loan term + 1 day" do
      loan.repayment_duration = {years: 3}
      loan.facility_letter_date = Date.new(2012, 10, 20)
      loan_guarantee.initial_draw_date = Date.new(2012, 11, 30)

      loan_guarantee.save

      loan.reload
      loan.maturity_date.should == Date.new(2015, 12, 1)
    end
  end
end
