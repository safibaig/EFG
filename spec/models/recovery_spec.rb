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
    ).each do |attr|
      it "requires #{attr}" do
        recovery.send("#{attr}=", '')
        recovery.should_not be_valid
      end
    end
  end
end
