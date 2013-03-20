require 'spec_helper'

describe AnnualPremiumPaymentCollection do
  describe '#to_a' do
    let(:collection) { AnnualPremiumPaymentCollection.new(premium_schedule) }

    before do
      premium_schedule.loan.premium_rate = 2.00
    end

    context 'when there is a single drawdown' do
      context 'and no repayment holiday' do
        let(:premium_schedule) {
          FactoryGirl.build_stubbed(:premium_schedule,
            repayment_duration: 24,
            initial_draw_amount: Money.new(350_000_00),
          )
        }

        it 'returns the correct premium payments' do
          collection.to_a.should == [
            BankersRoundingMoney.new(BigDecimal.new('175000')),
            BankersRoundingMoney.new(BigDecimal.new('175000')),
            BankersRoundingMoney.new(BigDecimal.new('175000')),
            BankersRoundingMoney.new(BigDecimal.new('175000')),
            BankersRoundingMoney.new(BigDecimal.new( '87500')),
            BankersRoundingMoney.new(BigDecimal.new( '87500')),
            BankersRoundingMoney.new(BigDecimal.new( '87500')),
            BankersRoundingMoney.new(BigDecimal.new( '87500')),
          ]
        end
      end
    end
  end
end

