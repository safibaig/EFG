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

    context 'when rescheduling' do
      let(:rescheduled_state_aid_calculation) { FactoryGirl.build(:rescheduled_state_aid_calculation) }

      it "does not require initial draw year" do
        rescheduled_state_aid_calculation.rescheduling = true
        rescheduled_state_aid_calculation.initial_draw_year = nil
        rescheduled_state_aid_calculation.should be_valid
      end

      %w(
        premium_cheque_month
        initial_draw_amount
        initial_draw_months
      ).each do |attr|
        it "is invalid without #{attr}" do
          rescheduled_state_aid_calculation.rescheduling = true
          rescheduled_state_aid_calculation.send("#{attr}=", '')
          rescheduled_state_aid_calculation.should_not be_valid
        end
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

  describe "sequence" do
    let(:state_aid_calculation) { FactoryGirl.build(:state_aid_calculation) }

    it "should be set before validation on create" do
      state_aid_calculation.seq.should be_nil
      state_aid_calculation.valid?
      state_aid_calculation.seq.should == 0
    end

    it "should increment by 1 when state aid calculation for the same loan exists" do
      state_aid_calculation.save!
      new_state_aid_calculation = FactoryGirl.build(:state_aid_calculation, loan: state_aid_calculation.loan)

      new_state_aid_calculation.valid?

      new_state_aid_calculation.seq.should == 1
    end
  end
end
