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
