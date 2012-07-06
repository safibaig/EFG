require 'spec_helper'

describe Recovery do
  describe 'validations' do
    let(:recovery) { FactoryGirl.build(:recovery) }

    it 'has a valid Factory' do
      recovery.should be_valid
    end

    it 'requires a loan' do
      recovery.loan = nil
      recovery.should_not be_valid
    end

    it 'requires a creator' do
      recovery.created_by = nil
      recovery.should_not be_valid
    end

    %w(
      recovered_on
      total_proceeds_recovered
      total_liabilities_after_demand
      total_liabilities_behind
      additional_break_costs
      additional_interest_accrued
      amount_due_to_dti
      realise_flag
      outstanding_non_efg_debt
      non_linked_security_proceeds
      linked_security_proceeds
      realisations_attributable
      realisations_due_to_gov
    ).each do |attr|
      it "requires #{attr}" do
        recovery.send("#{attr}=", '')
        recovery.should_not be_valid
      end
    end
  end
end
