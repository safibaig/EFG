require 'spec_helper'

describe SixMonthlyPremiumPaymentCollection do
  describe '#to_a' do
    let(:collection) { SixMonthlyPremiumPaymentCollection.new(premium_schedule) }

    before do
      premium_schedule.loan.premium_rate = 2.00
    end

    context 'when there is a single drawdown' do
      context 'and no repayment holiday' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 36,
            initial_draw_amount: Money.new(75_000_00),
          )
        }

        it 'returns the correct premium payments' do
          collection.to_a.should == [
            BankersRoundingMoney.new(BigDecimal.new('37500')),
            BankersRoundingMoney.new(BigDecimal.new('37500')),
            BankersRoundingMoney.new(BigDecimal.new('31250')),
            BankersRoundingMoney.new(BigDecimal.new('31250')),
            BankersRoundingMoney.new(BigDecimal.new('25000')),
            BankersRoundingMoney.new(BigDecimal.new('25000')),
            BankersRoundingMoney.new(BigDecimal.new('18750')),
            BankersRoundingMoney.new(BigDecimal.new('18750')),
            BankersRoundingMoney.new(BigDecimal.new('12500')),
            BankersRoundingMoney.new(BigDecimal.new('12500')),
            BankersRoundingMoney.new(BigDecimal.new( '6250')),
            BankersRoundingMoney.new(BigDecimal.new( '6250')),
          ]
        end
      end
    end
  end
end


