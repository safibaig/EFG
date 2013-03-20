require 'spec_helper'

describe QuarterlyPremiumPaymentCollection do
  it_should_behave_like 'a quarterly premium payment collection' do
    subject { QuarterlyPremiumPaymentCollection }
  end

  describe '#to_a' do
    context 'when the loan term does not contain an exact number of quarters' do
      let(:premium_schedule) {
        FactoryGirl.build_stubbed(:premium_schedule,
          repayment_duration: 50, # <-- not evenly divisible by 3
          initial_draw_amount: Money.new(50_000_00),
          initial_capital_repayment_holiday: 2,
        )
      }

      it 'returns the correct premium payments (one more than the legacy calculation)' do
        premium_schedule.loan.premium_rate = 2.00

        collection = QuarterlyPremiumPaymentCollection.new(premium_schedule)

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
          BankersRoundingMoney.new(BigDecimal.new( '1042')),
        ]
      end
    end
  end
end
