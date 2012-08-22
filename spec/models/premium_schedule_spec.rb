require 'spec_helper'

describe PremiumSchedule do
  describe "calculations" do
    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        initial_draw_amount: Money.new(100_000_00),
        initial_draw_months: 120)
    }

    let(:premium_schedule) {
      PremiumSchedule.new(state_aid_calculation, state_aid_calculation.loan)
    }

    it "calculates quarterly premiums" do
      [
        500_00, 487_50, 475_00, 462_50, 450_00, 437_50, 425_00, 412_50, 400_00,
        387_50, 375_00, 362_50, 350_00, 337_50, 325_00, 312_50, 300_00, 287_50,
        275_00, 262_50, 250_00, 237_50, 225_00, 212_50, 200_00, 187_50, 175_00,
        162_50, 150_00, 137_50, 125_00, 112_50, 100_00, 87_50, 75_00, 62_50,
        50_00, 37_50, 25_00, 12_50
      ].each.with_index do |premium, quarter|
        premium_schedule.premiums[quarter].should == Money.new(premium)
      end
    end

    it "calculates total premiums" do
      premium_schedule.total_premiums.should == Money.new(10_250_00)
    end

    context 'with weird initial_draw_months' do
      it 'does not blow up if the number of months is less than one quarter' do
        state_aid_calculation.initial_draw_months = 2

        premium_schedule.premiums[0].should == Money.new(500_00)
        premium_schedule.premiums[1].should be_zero
      end
    end

    context 'with second tranche draw down' do
      let(:loan) {
        FactoryGirl.build(:loan, amount: Money.new(1_000_000_00), repayment_duration: { months: 12 })
      }

      let(:state_aid_calculation) {
        FactoryGirl.build(
          :state_aid_calculation,
          loan: loan,
          initial_draw_amount: Money.new(900_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 0,
          second_draw_amount: Money.new(100_000_00),
          second_draw_months: 3
        )
      }

      it 'should correctly calculate premiums' do
        [ 4500_00, 3875_00, 2583_33, 1291_67, 0 ].each.with_index do |premium, quarter|
          premium_schedule.premiums[quarter].should == Money.new(premium)
        end
      end
    end

    context 'with second and third tranche draw downs' do
      let(:loan) {
        FactoryGirl.build(:loan, amount: Money.new(1_000_000_00), repayment_duration: { months: 12 })
      }

      let(:state_aid_calculation) {
        FactoryGirl.build(
          :state_aid_calculation,
          loan: loan,
          initial_draw_amount: Money.new(525_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 0,
          second_draw_amount: Money.new(350_500_00),
          second_draw_months: 2,
          third_draw_amount: Money.new(124_500_00),
          third_draw_months: 7
        )
      }

      it 'should correctly calculate premiums' do
        [ 2625_00, 3546_00, 2364_00, 1555_50, 0 ].each.with_index do |premium, quarter|
          premium_schedule.premiums[quarter].should == Money.new(premium)
        end
      end
    end

    context 'with second, third and fourth tranche draw downs' do
      let(:loan) {
        FactoryGirl.build(:loan, amount: Money.new(1_000_000_00), repayment_duration: { months: 12 })
      }

      let(:state_aid_calculation) {
        FactoryGirl.build(
          :state_aid_calculation,
          loan: loan,
          initial_draw_amount: Money.new(100_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 0,
          second_draw_amount: Money.new(50_000_00),
          second_draw_months: 3,
          third_draw_amount: Money.new(50_000_00),
          third_draw_months: 6,
          fourth_draw_amount: Money.new(800_000_00),
          fourth_draw_months: 9
        )
      }

      it 'should correctly calculate premiums' do
        [ 500_00, 625_00, 666_67, 4333_33, 0 ].each.with_index do |premium, quarter|
          premium_schedule.premiums[quarter].should == Money.new(premium)
        end
      end
    end

    context 'with payment holiday' do
      let(:loan) {
        FactoryGirl.build(:loan, amount: Money.new(1_000_000_00), repayment_duration: { months: 12 })
      }

      let(:state_aid_calculation) {
        FactoryGirl.build(
          :state_aid_calculation,
          loan: loan,
          initial_draw_amount: Money.new(100_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 3
        )
      }

      it 'should correctly calculate premiums' do
        [ 500_00, 500_00, 333_33, 166_67, 0 ].each.with_index do |premium, quarter|
          premium_schedule.premiums[quarter].should == Money.new(premium)
        end
      end
    end
  end

  describe "#subsequent_premiums" do

    let(:premium_schedule) { PremiumSchedule.new(state_aid_calculation, state_aid_calculation.loan) }

    context "when standard state aid calculation" do
      let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

      it "should not include first quarter when standard state aid calculation" do
        premium_schedule.subsequent_premiums.size.should == 39
      end
    end

    context "when rescheduled state aid calculation" do
      let(:state_aid_calculation) { FactoryGirl.build(:rescheduled_state_aid_calculation ) }

      it "should include first quarter when rescheduled state aid calculation" do
        premium_schedule.subsequent_premiums.size.should == 40
      end
    end
  end

  describe "#second_premium_collection_month" do
    let!(:loan) { FactoryGirl.build(:loan) }
    let!(:state_aid_calculation) { loan.state_aid_calculations.build }
    let!(:premium_schedule) { loan.premium_schedule }

    it "should return formatted date string 3 months from the initial draw date " do
      loan.initial_draw_date = Date.new(2012, 2, 24)

      premium_schedule.second_premium_collection_month.should == '05/2012'
    end

    it "should not screw up with end of month dates" do
      loan.initial_draw_date = Date.new(2011, 11, 30)

      premium_schedule.second_premium_collection_month.should == '02/2012'
    end

    it "should return nil if there is no initial draw date" do
      loan.initial_draw_date = nil

      premium_schedule.second_premium_collection_month.should be_nil
    end
  end
end
