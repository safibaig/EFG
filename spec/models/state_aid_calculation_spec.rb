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

  describe "agrees with training" do
    # https://www.sflg.gov.uk/training/action/loanDetail?ref=BM4YTG5%2B01
    it "for GBP 50,000 loan over 5 years" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation,
          initial_draw_amount: Money.new(50_000_00),
          initial_draw_months: 60)

      state_aid_calculation.state_aid_eur.should == Money.new(10_327_58, 'EUR')
    end

    # https://www.sflg.gov.uk/training/action/loanDetail?ref=GHKHZRF%2B01
    it "for a GBP 1,000,000 loan over 5 years" do
      state_aid_calculation = FactoryGirl.build(:state_aid_calculation,
          initial_draw_amount: Money.new(1_000_000_00),
          initial_draw_months: 60)

      state_aid_calculation.state_aid_eur.should == Money.new(179_500_05, 'EUR')
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
