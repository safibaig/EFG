require 'spec_helper'

shared_examples_for 'a draw amount validator' do
  before do
    subject.initial_draw_amount = Money.new(5_000_00)
    subject.second_draw_amount  = Money.new(1_000_00)
    subject.second_draw_months  = 1
    subject.third_draw_amount   = Money.new(1_000_00)
    subject.third_draw_months   = 2
    subject.fourth_draw_amount  = Money.new(1_000_00)
    subject.fourth_draw_months  = 3
  end

  context 'when the total of all draw amounts is equal to the loan amount' do
    context 'and there are no nil draw amounts' do
      before { loan.amount = Money.new(8_000_00) }

      it 'is valid' do
        subject.should be_valid
      end
    end

    context 'and there are nil draw amounts' do
      before do
        loan.amount = Money.new(7_000_00)
        subject.fourth_draw_amount = nil
      end

      it 'is valid' do
        subject.should be_valid
      end
    end
  end

  context 'when the total of all draw amounts is less than the loan amount' do
    before { loan.amount = Money.new(10_000_00) }

    context 'and there are no nil draw amounts' do
      it 'is valid' do
        subject.should be_valid
      end
    end

    context 'and there are nil draw amounts' do
      before { subject.fourth_draw_amount = nil }

      it 'is valid' do
        subject.should be_valid
      end
    end
  end

  context 'when the total of all draw amounts is greater than the loan amount' do
    before { loan.amount = Money.new(5_000_00) }

    context 'and there are no nil draw amounts' do
      it 'is not valid' do
        subject.should_not be_valid
      end
    end

    context 'and there are nil draw amounts' do
      before { subject.fourth_draw_amount = nil }

      it 'is not valid' do
        subject.should_not be_valid
      end
    end
  end
end

describe PremiumSchedule do

  let(:loan) { premium_schedule.loan }
  let(:premium_schedule) { FactoryGirl.build(:premium_schedule) }

  describe 'validations' do

    it 'has a valid Factory' do
      premium_schedule.should be_valid
    end

    it 'strictly requires a loan' do
      expect {
        premium_schedule.loan = nil
        premium_schedule.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    %w(
      initial_draw_year
      initial_draw_amount
      repayment_duration
    ).each do |attr|
      it "is invalid without #{attr}" do
        premium_schedule.send("#{attr}=", '')
        premium_schedule.should_not be_valid
      end
    end

    it 'is invalid when unable to derive the premium_calculation_strategy from the loan' do
      premium_schedule.premium_calculation_strategy = nil
      loan.repayment_frequency_id = nil
      premium_schedule.should_not be_valid
    end

    it 'requires initial draw amount to be 0 or more' do
      loan.amount = 0

      premium_schedule.initial_draw_amount = -1
      premium_schedule.should_not be_valid

      premium_schedule.initial_draw_amount = 0
      premium_schedule.should be_valid
    end

    it 'requires initial draw amount to be less than 9,999,999.99' do
      loan.amount = PremiumSchedule::MAX_INITIAL_DRAW

      premium_schedule.initial_draw_amount = PremiumSchedule::MAX_INITIAL_DRAW + Money.new(1)
      premium_schedule.should_not be_valid

      premium_schedule.initial_draw_amount = PremiumSchedule::MAX_INITIAL_DRAW
      premium_schedule.should be_valid
    end

    it 'requires an allowed calculation type' do
      premium_schedule.calc_type = nil
      premium_schedule.should_not be_valid

      premium_schedule.calc_type = "Z"
      premium_schedule.should_not be_valid

      premium_schedule.calc_type = PremiumSchedule::SCHEDULE_TYPE
      premium_schedule.should be_valid

      premium_schedule.calc_type = PremiumSchedule::NOTIFIED_AID_TYPE
      premium_schedule.should be_valid
    end

    %w(
      initial_capital_repayment_holiday
      second_draw_months
      third_draw_months
      fourth_draw_months
    ).each do |attr|
      it "does not require #{attr} if not set" do
        premium_schedule.initial_capital_repayment_holiday = nil
        premium_schedule.should be_valid
      end

      it "requires #{attr} to be 0 or greater if set" do
        premium_schedule.initial_capital_repayment_holiday = -1
        premium_schedule.should_not be_valid
        premium_schedule.initial_capital_repayment_holiday = 0
        premium_schedule.should be_valid
      end

      it "requires #{attr} to be 120 or less if set" do
        premium_schedule.initial_capital_repayment_holiday = 121
        premium_schedule.should_not be_valid
        premium_schedule.initial_capital_repayment_holiday = 120
        premium_schedule.should be_valid
      end
    end

    describe 'callbacks' do
      context 'on create' do
        context 'before validation' do
          it 'sets the premium_calculation_strategy based on the repayment frequency of the loan' do
            premium_schedule.premium_calculation_strategy = nil
            loan.repayment_frequency_id = 3
            premium_schedule.valid?
            premium_schedule.premium_calculation_strategy.should == 'quarterly'
          end
        end
      end
    end

    it_should_behave_like 'a draw amount validator' do
      subject { premium_schedule }
    end

    context 'when rescheduling' do
      let(:loan) { rescheduled_premium_schedule.loan }
      let(:rescheduled_premium_schedule) { FactoryGirl.build(:rescheduled_premium_schedule) }

      it_should_behave_like 'a draw amount validator' do
        subject { rescheduled_premium_schedule }
      end

      it "does not require initial draw year" do
        rescheduled_premium_schedule.initial_draw_year = nil
        rescheduled_premium_schedule.should be_valid
      end

      %w(
        premium_cheque_month
        initial_draw_amount
        repayment_duration
      ).each do |attr|
        it "is invalid without #{attr}" do
          rescheduled_premium_schedule.send("#{attr}=", '')
          rescheduled_premium_schedule.should_not be_valid
        end
      end

      it 'must have a correctly formatted premium_cheque_month' do
        rescheduled_premium_schedule.premium_cheque_month = 'blah'
        rescheduled_premium_schedule.should_not be_valid
        rescheduled_premium_schedule.premium_cheque_month = '1/12'
        rescheduled_premium_schedule.should_not be_valid
        rescheduled_premium_schedule.premium_cheque_month = '29/2015'
        rescheduled_premium_schedule.should_not be_valid
        rescheduled_premium_schedule.premium_cheque_month = '09/2015'
        rescheduled_premium_schedule.should be_valid
      end

      it "is not valid when premium cheque month is in the past" do
        rescheduled_premium_schedule.premium_cheque_month = "03/2012"
        rescheduled_premium_schedule.should_not be_valid
      end

      it "is not valid when premium cheque month is current month" do
        rescheduled_premium_schedule.premium_cheque_month = Date.today.strftime('%m/%Y')
        rescheduled_premium_schedule.should_not be_valid
      end

      it "is valid when premium cheque month is next month" do
        rescheduled_premium_schedule.premium_cheque_month = Date.today.next_month.strftime('%m/%Y')
        rescheduled_premium_schedule.should be_valid
      end

      it "is valid when premium cheque month number is less than current month but in a future year" do
        Timecop.freeze(Date.new(2012, 8, 23)) do
          rescheduled_premium_schedule.premium_cheque_month = "07/2013"
          rescheduled_premium_schedule.should be_valid
        end
      end

      it "is valid with differing values for loan amount and total draw amounth" do
        loan.amount = 10_000_00
        rescheduled_premium_schedule.initial_draw_amount = 10_00
        rescheduled_premium_schedule.should be_valid
      end
    end
  end

  context do

    let(:loan) { FactoryGirl.build(:loan, amount: Money.new(100_000_00)) }

    let(:premium_schedule) {
      FactoryGirl.build(:premium_schedule,
        loan: loan,
        initial_draw_amount: Money.new(50_000_00),
        repayment_duration: 24,
        initial_capital_repayment_holiday: 4,
        second_draw_amount: Money.new(25_000_00),
        second_draw_months: 13,
        third_draw_amount: Money.new(25_000_00),
        third_draw_months: 17
      )
    }

    describe "calculations" do
      it "calculates state aid in GBP" do
        premium_schedule.state_aid_gbp.should == Money.new(20_847_25, 'GBP')
      end

      it "calculates state aid in EUR" do
        PremiumSchedule.stub!(:current_euro_conversion_rate).and_return(1.1974)
        premium_schedule.state_aid_eur.should == Money.new(24_962_50, 'EUR')
      end
    end

    describe "saving a state aid calculation" do
      it "should store the state aid on the loan" do
        PremiumSchedule.stub!(:current_euro_conversion_rate).and_return(1.1974)

        loan.save!
        premium_schedule.save!

        loan.reload
        loan.state_aid.should == Money.new(24_962_50, 'EUR')
      end
    end
  end

  describe "sequence" do
    let(:premium_schedule) { FactoryGirl.build(:premium_schedule) }

    it "should be set before validation on create" do
      premium_schedule.seq.should be_nil
      premium_schedule.valid?
      premium_schedule.seq.should == 0
    end

    it "should increment by 1 when state aid calculation for the same loan exists" do
      premium_schedule.save!
      new_premium_schedule = FactoryGirl.build(:premium_schedule, loan: premium_schedule.loan)

      new_premium_schedule.valid?

      new_premium_schedule.seq.should == 1
    end
  end

  describe "reschedule?" do
    let(:premium_schedule) { FactoryGirl.build(:premium_schedule) }

    it "should return true when reschedule calculation type" do
      premium_schedule.calc_type = PremiumSchedule::RESCHEDULE_TYPE
      premium_schedule.should be_reschedule
    end

    it "should return false when schedule calculation type" do
      premium_schedule.calc_type = PremiumSchedule::SCHEDULE_TYPE
      premium_schedule.should_not be_reschedule
    end
  end

  describe "#euro_conversion_rate" do
    it "returns the default value" do
      premium_schedule = FactoryGirl.build(:premium_schedule)
      premium_schedule.euro_conversion_rate.should == PremiumSchedule.current_euro_conversion_rate
    end

    it "returns a set value" do
      premium_schedule = FactoryGirl.build(:premium_schedule, euro_conversion_rate: 0.65)
      premium_schedule.euro_conversion_rate.should == 0.65
    end

    it "saves the euro_conversion_rate used" do
      premium_schedule = FactoryGirl.create(:premium_schedule, euro_conversion_rate: 0.75)

      premium_schedule[:euro_conversion_rate].should == 0.75
    end
  end

  describe "reset_euro_conversion_rate" do
    it "clears the euro_conversion_rate so we get the current exchange rate" do
      premium_schedule = FactoryGirl.create(:premium_schedule, euro_conversion_rate: 0.80)

      premium_schedule.reset_euro_conversion_rate
      premium_schedule.euro_conversion_rate.should == PremiumSchedule.current_euro_conversion_rate
    end
  end

  describe '#total_premiums' do
    let(:premium_schedule) {
      FactoryGirl.build(:premium_schedule,
        initial_draw_amount: Money.new(100_000_00),
        repayment_duration: 120)
    }

    it 'calculates total premiums' do
      premium_schedule.loan.premium_rate = 2.0
      premium_schedule.total_premiums.should == Money.new(10_250_00)
    end
  end

  describe '#subsequent_premiums' do
    context 'when not a reschedule' do
      let(:premium_schedule) { FactoryGirl.build(:premium_schedule, repayment_duration: 120) }

      it 'should not include first quarter when standard state aid calculation' do
        premium_schedule.subsequent_premiums.size.should == 39
      end
    end

    context 'when a reschedule' do
      let(:premium_schedule) { FactoryGirl.build(:rescheduled_premium_schedule, repayment_duration: 120) }

      it 'should include first quarter when rescheduled state aid calculation' do
        premium_schedule.subsequent_premiums.size.should == 40
      end
    end
  end

  describe '#second_premium_collection_month' do
    let(:premium_schedule) { FactoryGirl.build(:premium_schedule, loan: loan) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it 'returns a formatted date string 3 months from the initial draw date ' do
      loan.initial_draw_change.update_attribute :date_of_change, Date.new(2012, 2, 24)

      premium_schedule.second_premium_collection_month.should == '05/2012'
    end

    it 'deals with end of month dates' do
      loan.initial_draw_change.update_attribute :date_of_change, Date.new(2011, 11, 30)

      premium_schedule.second_premium_collection_month.should == '02/2012'
    end

    it 'returns nil if there is no initial draw date' do
      loan.loan_modifications.delete_all

      premium_schedule.second_premium_collection_month.should be_nil
    end
  end

  describe '#initial_premium_cheque' do
    context 'when not reschedule' do
      let(:premium_schedule) {
        FactoryGirl.build(:premium_schedule,
          initial_draw_amount: Money.new(100_000_00),
          repayment_duration: 120)
      }

      it 'returns the first premium amount' do
        premium_schedule.initial_premium_cheque.should == premium_schedule.premiums.first
      end
    end

    context 'when a reschedule' do
      let(:premium_schedule) {
        FactoryGirl.build(:rescheduled_premium_schedule,
          initial_draw_amount: Money.new(100_000_00),
          repayment_duration: 120)
      }

      it 'returns 0 money' do
        premium_schedule.initial_premium_cheque.should == Money.new(0)
      end
    end
  end

  describe '#drawdowns' do
    let(:drawdowns) { premium_schedule.drawdowns }

    context 'when there is a single drawdown' do
      let(:premium_schedule) {
        FactoryGirl.build(:rescheduled_premium_schedule,
          initial_draw_amount: Money.new(100_000_00))
      }

      it 'returns an array containing one drawdown' do
        drawdowns.size.should == 1

        drawdowns[0].amount.should == Money.new(100_000_00)
        drawdowns[0].month.should == 0
      end
    end

    context 'when there are multiple drawdowns' do
      let(:premium_schedule) {
        FactoryGirl.build(:rescheduled_premium_schedule,
          initial_draw_amount: Money.new(100_000_00),
          second_draw_amount: Money.new(75_000_00),
          second_draw_months: 2,
          third_draw_amount: Money.new(50_000_00),
          third_draw_months: 4,
          fourth_draw_amount: Money.new(25_000_00),
          fourth_draw_months: 6)
      }

      it 'returns an array containing one drawdown' do
        drawdowns.size.should == 4

        drawdowns[0].amount.should == Money.new(100_000_00)
        drawdowns[0].month.should == 0

        drawdowns[1].amount.should == Money.new(75_000_00)
        drawdowns[1].month.should == 2

        drawdowns[2].amount.should == Money.new(50_000_00)
        drawdowns[2].month.should == 4

        drawdowns[3].amount.should == Money.new(25_000_00)
        drawdowns[3].month.should == 6
      end
    end
  end
end
