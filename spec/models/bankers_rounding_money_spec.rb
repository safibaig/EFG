require 'spec_helper'

describe BankersRoundingMoney do
  context 'when the amount contains a fractional number of pennies' do
    context 'and the fraction is exactly 0.5' do
      context 'and the number of whole pennies is even' do
        let(:money) { BankersRoundingMoney.new(BigDecimal.new('1014.50')) }

        it 'rounds down to the nearest whole even penny' do
          money.to_s.should == '10.14'
        end
      end

      context 'and the number of whole pennies is odd' do
        let(:money) { BankersRoundingMoney.new(BigDecimal.new('1015.50')) }

        it 'rounds up to the nearest whole even penny' do
          money.to_s.should == '10.16'
        end
      end
    end

    context 'and the fraction of pennies is greater than 0.5' do
      let(:money) { BankersRoundingMoney.new(BigDecimal.new('1018.5001')) }

      it 'rounds up to the nearest penny' do
        money.to_s.should == '10.19'
      end
    end

    context 'and the fraction of pennies is less than 0.5' do
      let(:money) { BankersRoundingMoney.new(BigDecimal.new('1017.4999')) }

      it 'rounds down to the nearest penny' do
        money.to_s.should == '10.17'
      end
    end
  end

  context 'when the amount does not contain a fractional number of pennies' do
    let(:money) { BankersRoundingMoney.new(BigDecimal.new('1025.00')) }

    it 'returns the same amount' do
      money.to_s.should == '10.25'
    end
  end
end
