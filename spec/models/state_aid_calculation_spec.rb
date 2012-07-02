require 'spec_helper'

describe StateAidCalculation do
  describe 'validations' do
    let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

    it 'has a valid Factory' do
      state_aid_calculation.should be_valid
    end

    it 'requires a loan' do
      state_aid_calculation.loan = nil
      state_aid_calculation.should_not be_valid
    end

    %w(
      initial_draw_year
      initial_draw_amount
      initial_draw_months
    ).each do |attr|
      it "is invalid without #{attr}" do
        state_aid_calculation.send("#{attr}=", '')
        state_aid_calculation.should_not be_valid
      end
    end
  end

  describe "calculations" do
    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        initial_draw_amount: Money.new(100_000_00),
        initial_draw_months: 120)
    }

    it "calcuates quarterly premiums" do
      [
        500_00, 487_50, 475_00, 462_50, 450_00, 437_50, 425_00, 412_50, 400_00,
        387_50, 375_00, 362_50, 350_00, 337_50, 325_00, 312_50, 300_00, 287_50,
        275_00, 262_50, 250_00, 237_50, 225_00, 212_50, 200_00, 187_50, 175_00,
        162_50, 150_00, 137_50, 125_00, 112_50, 100_00, 87_50, 75_00, 62_50,
        50_00, 37_50, 25_00, 12_50
      ].each.with_index do |premium, quarter|
        state_aid_calculation.premiums[quarter].should == Money.new(premium)
      end
    end

    it "calculates total premiums" do
      state_aid_calculation.total_premiums.should == Money.new(10_250_00)
    end

    it "calculates state aid in GBP" do
      state_aid_calculation.state_aid_gbp.should == Money.new(12_250_00, 'GBP')
    end

    it "calculates state aid in EUR" do
      state_aid_calculation.state_aid_eur.should == Money.new(14_668_15, 'EUR')
    end
  end

  describe "saving a state aid calculation" do
    it "should store the state aid on the loan" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation, initial_draw_amount: Money.new(100_000_00), initial_draw_months: 120)
      loan = state_aid_calculation.loan
      state_aid_calculation.save

      loan.reload
      loan.state_aid.should == Money.new(14_668_15, 'EUR')
    end
  end
end
