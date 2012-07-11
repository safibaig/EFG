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

    it 'recovered_on must be after its loan was settled' do
      recovery.loan.settled_on = Date.today
      recovery.recovered_on = 1.day.ago
      recovery.should_not be_valid
    end

    %w(
      recovered_on
      outstanding_non_efg_debt
      non_linked_security_proceeds
      linked_security_proceeds
    ).each do |attr|
      it "requires #{attr}" do
        recovery.send("#{attr}=", '')
        recovery.should_not be_valid
      end
    end
  end
end
