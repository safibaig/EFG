require 'spec_helper'

describe StateAidCalculation do
  describe 'validations' do
    let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

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
      state_aid_calculation.initial_draw_amount = -1
      state_aid_calculation.should_not be_valid

      state_aid_calculation.initial_draw_amount = 0
      state_aid_calculation.should be_valid
    end

    it 'requires initial draw amount to be less than 9,999,999.99' do
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

    context 'when rescheduling' do
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
        Date.stub(:today).and_return(Date.parse("23/08/2012"))

        rescheduled_state_aid_calculation.premium_cheque_month = "07/2013"
        rescheduled_state_aid_calculation.should be_valid
      end

      it 'requires an allowed calculation type' do
        state_aid_calculation.calc_type = StateAidCalculation::SCHEDULE_TYPE
        state_aid_calculation.should be_valid
      end
    end
  end

  describe "calculations" do
    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        initial_draw_amount: Money.new(100_000_00),
        initial_draw_months: 120)
    }

    it "calculates state aid in GBP" do
      state_aid_calculation.state_aid_gbp.should == Money.new(12_250_00, 'GBP')
    end

    it "calculates state aid in EUR" do
      state_aid_calculation.state_aid_eur.should == Money.new(14_668_15, 'EUR')
    end
  end

  describe "saving a state aid calculation" do
    it "should store the state aid on the loan" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation, initial_draw_amount: Money.new(100_000_00), initial_draw_months: 120)
      loan = state_aid_calculation.loan
      state_aid_calculation.save

      loan.reload
      loan.state_aid.should == Money.new(14_668_15, 'EUR')
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
end
