require 'spec_helper'

describe PremiumScheduleQuarter do

  let(:premium_schedule) {
    PremiumSchedule.new(state_aid_calculation, state_aid_calculation.loan)
  }

  let(:loan) {
    FactoryGirl.build(:loan, amount: Money.new(1_000_000_00), repayment_duration: { months: 12 })
  }

  describe '#premium_amount' do
    context 'with second tranche drawdown' do

      let(:state_aid_calculation) {
        FactoryGirl.build(
          :state_aid_calculation,
          loan: loan,
          initial_draw_year: 2012,
          initial_draw_amount: Money.new(900_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 0,
          second_draw_amount: Money.new(100_000_00),
          second_draw_months: 3,
          calc_type: 'S',
          premium_cheque_month: ''
        )
      }

      it 'should return correct premium amounts' do
        [ 4500_00, 3875_00, 2583_33, 1291_67, 0 ].each.with_index do |premium, quarter|
          PremiumScheduleQuarter.new(quarter, 4, premium_schedule).premium_amount.should == Money.new(premium)
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
          initial_draw_amount: Money.new(10_000_00),
          initial_draw_months: 12,
          initial_capital_repayment_holiday: 5
        )
      }

      it 'should correctly calculate premiums' do
        [ 50_00, 50_00, 42_86, 21_43, 0 ].each.with_index do |premium, quarter|
          PremiumScheduleQuarter.new(quarter, 4, premium_schedule).premium_amount.should == Money.new(premium)
        end
      end
    end
  end

end
