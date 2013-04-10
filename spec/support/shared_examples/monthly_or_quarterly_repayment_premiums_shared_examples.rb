shared_examples_for 'premium payments for a loan repaid on a monthly or quarterly basis' do
  before do
    premium_schedule.loan.premium_rate = 2.00
    premium_schedule.loan.repayment_frequency_id = repayment_frequency.id
  end

  context 'when the loan term contains an exact number of quarters' do
    context 'and all drawdowns are on quarter months' do
      context 'when there is a single drawdown' do
        context 'and no repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 63,
              initial_draw_amount: Money.new(7_137_65),
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
              BankersRoundingMoney.new(BigDecimal.new('3569')),
              BankersRoundingMoney.new(BigDecimal.new('3399')),
              BankersRoundingMoney.new(BigDecimal.new('3229')),
              BankersRoundingMoney.new(BigDecimal.new('3059')),
              BankersRoundingMoney.new(BigDecimal.new('2889')),
              BankersRoundingMoney.new(BigDecimal.new('2719')),
              BankersRoundingMoney.new(BigDecimal.new('2549')),
              BankersRoundingMoney.new(BigDecimal.new('2379')),
              BankersRoundingMoney.new(BigDecimal.new('2209')),
              BankersRoundingMoney.new(BigDecimal.new('2039')),
              BankersRoundingMoney.new(BigDecimal.new('1869')),
              BankersRoundingMoney.new(BigDecimal.new('1699')),
              BankersRoundingMoney.new(BigDecimal.new('1530')),
              BankersRoundingMoney.new(BigDecimal.new('1360')),
              BankersRoundingMoney.new(BigDecimal.new('1190')),
              BankersRoundingMoney.new(BigDecimal.new('1020')),
              BankersRoundingMoney.new(BigDecimal.new( '850')),
              BankersRoundingMoney.new(BigDecimal.new( '680')),
              BankersRoundingMoney.new(BigDecimal.new( '510')),
              BankersRoundingMoney.new(BigDecimal.new( '340')),
              BankersRoundingMoney.new(BigDecimal.new( '170')),
            ]
          end
        end

        context 'and a repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 24,
              initial_capital_repayment_holiday: 12,
              initial_draw_amount: Money.new(160_000_00),
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
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

      context 'when there are two drawdowns taken on quarter months' do
        context 'and no repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 60,
              initial_draw_amount: Money.new(300_000_00),
              second_draw_amount: Money.new(100_000_00),
              second_draw_months: 3,
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
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
      end

      context 'when there are three drawdowns taken on quarter months' do
        context 'and no repayment holiday' do
          let(:premium_schedule) {
            FactoryGirl.build_stubbed(:premium_schedule,
              repayment_duration: 12,
              initial_draw_amount: Money.new(12_000_00),
              second_draw_amount: Money.new(12_000_00),
              second_draw_months: 3,
              third_draw_amount: Money.new(12_000_00),
              third_draw_months: 6,
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
              BankersRoundingMoney.new(BigDecimal.new( '6000')),
              BankersRoundingMoney.new(BigDecimal.new('10500')),
              BankersRoundingMoney.new(BigDecimal.new('13000')),
              BankersRoundingMoney.new(BigDecimal.new( '6500'))
            ]
          end
        end
      end

      context 'when there are four drawdowns taken on quarter months' do
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
              fourth_draw_months: 9,
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
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
              legacy_premium_calculation: legacy_premium_calculation,
            )
          }

          it 'returns the correct premium payments' do
            premium_schedule.premiums.should == [
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

      context 'when there is a second drawdown in month 0' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 30,
            initial_draw_amount: Money.new(10_000_00),
            second_draw_amount: Money.new(10_000_00),
            second_draw_months: 0,
            legacy_premium_calculation: legacy_premium_calculation,
          )
        }

        it 'does not ignore the second drawdown and returns the correct premium payments' do
          premium_schedule.premiums.should == [
            BankersRoundingMoney.new(BigDecimal.new('10000')),
            BankersRoundingMoney.new(BigDecimal.new( '9000')),
            BankersRoundingMoney.new(BigDecimal.new( '8000')),
            BankersRoundingMoney.new(BigDecimal.new( '7000')),
            BankersRoundingMoney.new(BigDecimal.new( '6000')),
            BankersRoundingMoney.new(BigDecimal.new( '5000')),
            BankersRoundingMoney.new(BigDecimal.new( '4000')),
            BankersRoundingMoney.new(BigDecimal.new( '3000')),
            BankersRoundingMoney.new(BigDecimal.new( '2000')),
            BankersRoundingMoney.new(BigDecimal.new( '1000')),
          ]
        end
      end

      context 'when the repayment duration is less than one quarter' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 2,
            initial_draw_amount: Money.new(100_000_00),
            legacy_premium_calculation: legacy_premium_calculation,
          )
        }

        it 'returns the correct single premium payment' do
          premium_schedule.premiums.should == [
            BankersRoundingMoney.new(BigDecimal.new('50000'))
          ]
        end
      end
    end
  end
end
