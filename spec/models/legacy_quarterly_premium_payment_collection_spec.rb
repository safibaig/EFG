require 'spec_helper'

describe LegacyQuarterlyPremiumPaymentCollection do
  let(:collection) { LegacyQuarterlyPremiumPaymentCollection.new(premium_schedule) }

  before do
    premium_schedule.loan.premium_rate = 2.00
  end

  describe '#to_a' do
    context 'when there is a single drawdown' do
      context 'and no repayment holiday' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 60,
            initial_draw_amount: Money.new(20_000_00),
          )
        }

        it 'returns the correct premium payments' do
          collection.to_a.should == [
            BankersRoundingMoney.new(BigDecimal.new('10000')),
            BankersRoundingMoney.new(BigDecimal.new( '9500')),
            BankersRoundingMoney.new(BigDecimal.new( '9000')),
            BankersRoundingMoney.new(BigDecimal.new( '8500')),
            BankersRoundingMoney.new(BigDecimal.new( '8000')),
            BankersRoundingMoney.new(BigDecimal.new( '7500')),
            BankersRoundingMoney.new(BigDecimal.new( '7000')),
            BankersRoundingMoney.new(BigDecimal.new( '6500')),
            BankersRoundingMoney.new(BigDecimal.new( '6000')),
            BankersRoundingMoney.new(BigDecimal.new( '5500')),
            BankersRoundingMoney.new(BigDecimal.new( '5000')),
            BankersRoundingMoney.new(BigDecimal.new( '4500')),
            BankersRoundingMoney.new(BigDecimal.new( '4000')),
            BankersRoundingMoney.new(BigDecimal.new( '3500')),
            BankersRoundingMoney.new(BigDecimal.new( '3000')),
            BankersRoundingMoney.new(BigDecimal.new( '2500')),
            BankersRoundingMoney.new(BigDecimal.new( '2000')),
            BankersRoundingMoney.new(BigDecimal.new( '1500')),
            BankersRoundingMoney.new(BigDecimal.new( '1000')),
            BankersRoundingMoney.new(BigDecimal.new(  '500'))
          ]
        end
      end

      context 'and a repayment holiday' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 24,
            initial_capital_repayment_holiday: 12,
            initial_draw_amount: Money.new(160_000_00),
          )
        }

        it 'returns the correct premium payments' do
          collection.to_a.should == [
            BankersRoundingMoney.new(BigDecimal.new('80000')),
            BankersRoundingMoney.new(BigDecimal.new('80000')),
            BankersRoundingMoney.new(BigDecimal.new('80000')),
            BankersRoundingMoney.new(BigDecimal.new('80000')),
            BankersRoundingMoney.new(BigDecimal.new('80000')),
            BankersRoundingMoney.new(BigDecimal.new('60000')),
            BankersRoundingMoney.new(BigDecimal.new('40000')),
            BankersRoundingMoney.new(BigDecimal.new('20000')),
          ]
        end
      end
    end

    context 'when there are two drawdowns' do
      context 'and no repayment holiday' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 60,
            initial_draw_amount: Money.new(300_000_00),
            second_draw_amount: Money.new(100_000_00),
            second_draw_months: 3,
          )
        }

        it 'returns the correct premium payments' do
          collection.to_a.should == [
            BankersRoundingMoney.new(BigDecimal.new('150000')),
            BankersRoundingMoney.new(BigDecimal.new('192500')),
            BankersRoundingMoney.new(BigDecimal.new('182368')),
            BankersRoundingMoney.new(BigDecimal.new('172237')),
            BankersRoundingMoney.new(BigDecimal.new('162105')),
            BankersRoundingMoney.new(BigDecimal.new('151974')),
            BankersRoundingMoney.new(BigDecimal.new('141842')),
            BankersRoundingMoney.new(BigDecimal.new('131711')),
            BankersRoundingMoney.new(BigDecimal.new('121579')),
            BankersRoundingMoney.new(BigDecimal.new('111447')),
            BankersRoundingMoney.new(BigDecimal.new('101316')),
            BankersRoundingMoney.new(BigDecimal.new( '91184')),
            BankersRoundingMoney.new(BigDecimal.new( '81053')),
            BankersRoundingMoney.new(BigDecimal.new( '70921')),
            BankersRoundingMoney.new(BigDecimal.new( '60789')),
            BankersRoundingMoney.new(BigDecimal.new( '50658')),
            BankersRoundingMoney.new(BigDecimal.new( '40526')),
            BankersRoundingMoney.new(BigDecimal.new( '30395')),
            BankersRoundingMoney.new(BigDecimal.new( '20263')),
            BankersRoundingMoney.new(BigDecimal.new( '10132'))
          ]
        end
      end

      context 'when there are three drawdowns' do
        context 'and no repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 12,
              initial_draw_amount: Money.new(525_000_00),
              second_draw_amount: Money.new(350_500_00),
              second_draw_months: 2,
              third_draw_amount: Money.new(124_500_00),
              third_draw_months: 7
            )
          }

          it 'returns the correct premium payments' do
            collection.to_a.should == [
              BankersRoundingMoney.new(BigDecimal.new('262500')),
              BankersRoundingMoney.new(BigDecimal.new('354600')),
              BankersRoundingMoney.new(BigDecimal.new('236400')),
              BankersRoundingMoney.new(BigDecimal.new('155550'))
            ]
          end
        end
      end

      context 'when there are four drawdowns' do
        context 'and no repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build(:premium_schedule,
              initial_draw_amount: Money.new(100_000_00),
              repayment_duration: 12,
              second_draw_amount: Money.new(50_000_00),
              second_draw_months: 3,
              third_draw_amount: Money.new(50_000_00),
              third_draw_months: 6,
              fourth_draw_amount: Money.new(800_000_00),
              fourth_draw_months: 9
            )
          }

          it 'returns the correct premium payments' do
            collection.to_a.should == [
              BankersRoundingMoney.new(BigDecimal.new( '50000')),
              BankersRoundingMoney.new(BigDecimal.new( '62500')),
              BankersRoundingMoney.new(BigDecimal.new( '66667')),
              BankersRoundingMoney.new(BigDecimal.new('433333'))
            ]
          end
        end

        context 'and a repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 60,
              initial_capital_repayment_holiday: 6,
              initial_draw_amount: Money.new(100_000_00),
              second_draw_amount: Money.new(100_000_00),
              second_draw_months: 1,
              third_draw_amount: Money.new(100_000_00),
              third_draw_months: 2,
              fourth_draw_amount: Money.new(200_000_00),
              fourth_draw_months: 3,
            )
          }

          it 'returns the correct premium payments' do
            collection.to_a.should == [
              BankersRoundingMoney.new(BigDecimal.new( '50000')),
              BankersRoundingMoney.new(BigDecimal.new('250000')),
              BankersRoundingMoney.new(BigDecimal.new('250000')),
              BankersRoundingMoney.new(BigDecimal.new('236111')),
              BankersRoundingMoney.new(BigDecimal.new('222222')),
              BankersRoundingMoney.new(BigDecimal.new('208333')),
              BankersRoundingMoney.new(BigDecimal.new('194444')),
              BankersRoundingMoney.new(BigDecimal.new('180556')),
              BankersRoundingMoney.new(BigDecimal.new('166667')),
              BankersRoundingMoney.new(BigDecimal.new('152778')),
              BankersRoundingMoney.new(BigDecimal.new('138889')),
              BankersRoundingMoney.new(BigDecimal.new('125000')),
              BankersRoundingMoney.new(BigDecimal.new('111111')),
              BankersRoundingMoney.new(BigDecimal.new( '97222')),
              BankersRoundingMoney.new(BigDecimal.new( '83333')),
              BankersRoundingMoney.new(BigDecimal.new( '69444')),
              BankersRoundingMoney.new(BigDecimal.new( '55556')),
              BankersRoundingMoney.new(BigDecimal.new( '41667')),
              BankersRoundingMoney.new(BigDecimal.new( '27778')),
              BankersRoundingMoney.new(BigDecimal.new( '13889'))
            ]
          end
        end
      end
    end

    context 'when the loan term does not contain an exact number of quarters' do
      let(:premium_schedule) {
        FactoryGirl.build_stubbed(:premium_schedule,
          repayment_duration: 50, # <-- not evenly divisible by 3
          initial_draw_amount: Money.new(50_000_00),
          initial_capital_repayment_holiday: 2,
        )
      }

      it 'returns the correct premium payments, missing off the final one' do
        collection.to_a.should == [
          BankersRoundingMoney.new(BigDecimal.new('25000')),
          BankersRoundingMoney.new(BigDecimal.new('24479')),
          BankersRoundingMoney.new(BigDecimal.new('22917')),
          BankersRoundingMoney.new(BigDecimal.new('21354')),
          BankersRoundingMoney.new(BigDecimal.new('19792')),
          BankersRoundingMoney.new(BigDecimal.new('18229')),
          BankersRoundingMoney.new(BigDecimal.new('16667')),
          BankersRoundingMoney.new(BigDecimal.new('15104')),
          BankersRoundingMoney.new(BigDecimal.new('13542')),
          BankersRoundingMoney.new(BigDecimal.new('11979')),
          BankersRoundingMoney.new(BigDecimal.new('10417')),
          BankersRoundingMoney.new(BigDecimal.new( '8854')),
          BankersRoundingMoney.new(BigDecimal.new( '7292')),
          BankersRoundingMoney.new(BigDecimal.new( '5729')),
          BankersRoundingMoney.new(BigDecimal.new( '4167')),
          BankersRoundingMoney.new(BigDecimal.new( '2604')),
        ]
      end
    end

    context 'when the repayment duration is less than one quarter' do
      let(:premium_schedule) {
        FactoryGirl.build_stubbed(:premium_schedule,
          repayment_duration: 2,
          initial_draw_amount: Money.new(100_000_00),
        )
      }

      it 'returns the correct single premium payment' do
        collection.to_a.should == [
          BankersRoundingMoney.new(BigDecimal.new('50000'))
        ]
      end
    end
  end
end
