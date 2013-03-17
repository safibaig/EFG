require 'spec_helper'

describe InterestOnlyPremiumPaymentCollection do
  let(:collection) { InterestOnlyPremiumPaymentCollection.new(premium_schedule) }

  let(:premium_schedule) {
    FactoryGirl.build_stubbed(:premium_schedule, loan: loan, repayment_duration: months)
  }

  let(:loan) { FactoryGirl.build_stubbed(:loan) }

  describe '#to_a' do
    let(:loan) {
      FactoryGirl.build_stubbed(:loan,
        amount: Money.new(600_000_00),
        premium_rate: 2.00
      )
    }

    context 'when there is a single drawdown' do
      let(:premium_schedule) {
        FactoryGirl.build_stubbed(:premium_schedule,
          repayment_duration: 4,
          initial_draw_amount: Money.new(600_000_00),
          loan: loan
        )
      }

      it 'returns the correct premium payments' do
        collection.to_a.should == [
          BankersRoundingMoney.new(BigDecimal.new('300000')),
          BankersRoundingMoney.new(BigDecimal.new('300000'))
        ]
      end
    end

    context 'when there are multiple drawdowns' do
      let(:premium_schedule) {
        FactoryGirl.build_stubbed(:premium_schedule,
          repayment_duration: 4,
          initial_draw_amount: Money.new(300_000_00),
          second_draw_amount: Money.new(300_000_00),
          second_draw_months: 2,
          loan: loan
        )
      }

      it 'returns the correct premium payments' do
        collection.to_a.should == [
          BankersRoundingMoney.new(BigDecimal.new('150000')),
          BankersRoundingMoney.new(BigDecimal.new('300000'))
        ]
      end
    end
  end
end
