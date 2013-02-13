require 'spec_helper'

describe StateAidCalculation do

  let(:loan) { state_aid_calculation.loan }
  let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

  describe 'validations' do

    it 'has a valid Factory' do
      state_aid_calculation.should be_valid
    end

    it 'requires a loan' do
      state_aid_calculation.loan = nil
      state_aid_calculation.should_not be_valid
    end

    %w(
      initial_draw_year
      initial_draw_amount
      initial_draw_months
    ).each do |attr|
      it "is invalid without #{attr}" do
        state_aid_calculation.send("#{attr}=", '')
        state_aid_calculation.should_not be_valid
      end
    end

    it 'requires initial draw amount to be 0 or more' do
      loan.amount = 0

      state_aid_calculation.initial_draw_amount = -1
      state_aid_calculation.should_not be_valid

      state_aid_calculation.initial_draw_amount = 0
      state_aid_calculation.should be_valid
    end

    it 'requires initial draw amount to be less than 9,999,999.99' do
      loan.amount = StateAidCalculation::MAX_INITIAL_DRAW

      state_aid_calculation.initial_draw_amount = StateAidCalculation::MAX_INITIAL_DRAW + Money.new(1)
      state_aid_calculation.should_not be_valid

      state_aid_calculation.initial_draw_amount = StateAidCalculation::MAX_INITIAL_DRAW
      state_aid_calculation.should be_valid
    end

    it 'requires an allowed calculation type' do
      state_aid_calculation.calc_type = nil
      state_aid_calculation.should_not be_valid

      state_aid_calculation.calc_type = "Z"
      state_aid_calculation.should_not be_valid

      state_aid_calculation.calc_type = StateAidCalculation::SCHEDULE_TYPE
      state_aid_calculation.should be_valid

      state_aid_calculation.calc_type = StateAidCalculation::NOTIFIED_AID_TYPE
      state_aid_calculation.should be_valid
    end

    %w(
      initial_capital_repayment_holiday
      second_draw_months
      third_draw_months
      fourth_draw_months
    ).each do |attr|
      it "does not require #{attr} if not set" do
        state_aid_calculation.initial_capital_repayment_holiday = nil
        state_aid_calculation.should be_valid
      end

      it "requires #{attr} to be 0 or greater if set" do
        state_aid_calculation.initial_capital_repayment_holiday = -1
        state_aid_calculation.should_not be_valid
        state_aid_calculation.initial_capital_repayment_holiday = 0
        state_aid_calculation.should be_valid
      end

      it "requires #{attr} to be 120 or less if set" do
        state_aid_calculation.initial_capital_repayment_holiday = 121
        state_aid_calculation.should_not be_valid
        state_aid_calculation.initial_capital_repayment_holiday = 120
        state_aid_calculation.should be_valid
      end
    end

    it "requires that the sum of initial_draw_amount, second_draw_amount, third_draw_amount, fourth_draw_amount equal the loan amount" do
      loan.amount = Money.new(10_000_00)
      state_aid_calculation.initial_draw_amount = Money.new(6_000_00)
      state_aid_calculation.second_draw_amount = Money.new(2_000_00)
      state_aid_calculation.third_draw_amount = Money.new(2_000_00)
      state_aid_calculation.fourth_draw_amount = Money.new(2_000_00)

      state_aid_calculation.should_not be_valid
    end

    it "validates the loan amount correctly with nil values for draw amounts" do
      loan = state_aid_calculation.loan
      loan.amount = Money.new(10_000_00)
      state_aid_calculation.initial_draw_amount = Money.new(6_000_00)
      state_aid_calculation.second_draw_amount = nil
      state_aid_calculation.third_draw_amount = nil
      state_aid_calculation.fourth_draw_amount = nil

      state_aid_calculation.should_not be_valid
    end

    context 'when rescheduling' do
      let(:loan) { rescheduled_state_aid_calculation.loan }
      let(:rescheduled_state_aid_calculation) { FactoryGirl.build(:rescheduled_state_aid_calculation) }

      it "does not require initial draw year" do
        rescheduled_state_aid_calculation.initial_draw_year = nil
        rescheduled_state_aid_calculation.should be_valid
      end

      %w(
        premium_cheque_month
        initial_draw_amount
        initial_draw_months
      ).each do |attr|
        it "is invalid without #{attr}" do
          rescheduled_state_aid_calculation.send("#{attr}=", '')
          rescheduled_state_aid_calculation.should_not be_valid
        end
      end

      it 'must have a correctly formatted premium_cheque_month' do
        rescheduled_state_aid_calculation.premium_cheque_month = 'blah'
        rescheduled_state_aid_calculation.should_not be_valid
        rescheduled_state_aid_calculation.premium_cheque_month = '1/12'
        rescheduled_state_aid_calculation.should_not be_valid
        rescheduled_state_aid_calculation.premium_cheque_month = '29/2015'
        rescheduled_state_aid_calculation.should_not be_valid
        rescheduled_state_aid_calculation.premium_cheque_month = '09/2015'
        rescheduled_state_aid_calculation.should be_valid
      end

      it "is not valid when premium cheque month is in the past" do
        rescheduled_state_aid_calculation.premium_cheque_month = "03/2012"
        rescheduled_state_aid_calculation.should_not be_valid
      end

      it "is not valid when premium cheque month is current month" do
        rescheduled_state_aid_calculation.premium_cheque_month = Date.today.strftime('%m/%Y')
        rescheduled_state_aid_calculation.should_not be_valid
      end

      it "is valid when premium cheque month is next month" do
        rescheduled_state_aid_calculation.premium_cheque_month = Date.today.next_month.strftime('%m/%Y')
        rescheduled_state_aid_calculation.should be_valid
      end

      it "is valid when premium cheque month number is less than current month but in a future year" do
        Timecop.freeze(Date.new(2012, 8, 23)) do
          rescheduled_state_aid_calculation.premium_cheque_month = "07/2013"
          rescheduled_state_aid_calculation.should be_valid
        end
      end

      it "is valid with differing values for loan amount and total draw amounth" do
        loan.amount = 10_000_00
        rescheduled_state_aid_calculation.initial_draw_amount = 10_00
        rescheduled_state_aid_calculation.should be_valid
      end
    end
  end

  context do

    let(:loan) { FactoryGirl.build(:loan, amount: Money.new(100_000_00)) }

    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        loan: loan,
        initial_draw_amount: Money.new(50_000_00),
        initial_draw_months: 24,
        initial_capital_repayment_holiday: 4,
        second_draw_amount: Money.new(25_000_00),
        second_draw_months: 13,
        third_draw_amount: Money.new(25_000_00),
        third_draw_months: 17
      )
    }

    describe "calculations" do
      it "calculates state aid in GBP" do
        state_aid_calculation.state_aid_gbp.should == Money.new(20_847_25, 'GBP')
      end

      it "calculates state aid in EUR" do
        state_aid_calculation.state_aid_eur.should == Money.new(24_962_50, 'EUR')
      end
    end

    describe "saving a state aid calculation" do
      it "should store the state aid on the loan" do
        loan.save!
        state_aid_calculation.save!

        loan.reload
        loan.state_aid.should == Money.new(24_962_50, 'EUR')
      end
    end
  end

  describe "sequence" do
    let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

    it "should be set before validation on create" do
      state_aid_calculation.seq.should be_nil
      state_aid_calculation.valid?
      state_aid_calculation.seq.should == 0
    end

    it "should increment by 1 when state aid calculation for the same loan exists" do
      state_aid_calculation.save!
      new_state_aid_calculation = FactoryGirl.build(:state_aid_calculation, loan: state_aid_calculation.loan)

      new_state_aid_calculation.valid?

      new_state_aid_calculation.seq.should == 1
    end
  end

  describe "reschedule?" do
    let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

    it "should return true when reschedule calculation type" do
      state_aid_calculation.calc_type = StateAidCalculation::RESCHEDULE_TYPE
      state_aid_calculation.should be_reschedule
    end

    it "should return false when schedule calculation type" do
      state_aid_calculation.calc_type = StateAidCalculation::SCHEDULE_TYPE
      state_aid_calculation.should_not be_reschedule
    end
  end

  describe "#euro_conversion_rate" do
    it "returns the default value" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation)
      state_aid_calculation.euro_conversion_rate.should == 1.1974
    end

    it "returns a set value" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation, euro_conversion_rate: 0.65)
      state_aid_calculation.euro_conversion_rate.should == 0.65
    end

    it "saves the euro_conversion_rate used" do
      state_aid_calculation = FactoryGirl.create(:state_aid_calculation, euro_conversion_rate: 0.75)

      state_aid_calculation[:euro_conversion_rate].should == 0.75
    end
  end
end
