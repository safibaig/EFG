require 'spec_helper'

describe GovernmentGuaranteeClaimCalculation do

  include GovernmentGuaranteeClaimCalculation

  describe "#calculate_dti_amount_claimed" do
    context 'for EFG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding" do
        calculate_dti_amount_claimed(loan).should == Money.new(750_00)
      end
    end

    context 'for SFLG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          dti_interest: Money.new(500_00),
          dti_break_costs: Money.new(200_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding, interest and break costs" do
        calculate_dti_amount_claimed(loan).should == Money.new(1_275_00)
      end
    end

    context 'for legacy SFLG loan' do
      let(:loan) {
        FactoryGirl.build(
          :loan,
          :legacy_sflg,
          dti_demand_outstanding: Money.new(1_000_00),
          dti_interest: Money.new(500_00),
          dti_break_costs: Money.new(200_00),
          guarantee_rate: 75
        )
      }

      it "calculates dti_amount_claimed based on demand outstanding, interest and break costs" do
        calculate_dti_amount_claimed(loan).should == Money.new(1_275_00)
      end
    end

    context 'loan without demand outstanding, interest or break cost values' do
      let(:loan) { FactoryGirl.build(:loan, guarantee_rate: 75) }

      it "returns 0 when relevant values are not set on loan" do
        calculate_dti_amount_claimed(loan).should == Money.new(0)
      end
    end
  end
end