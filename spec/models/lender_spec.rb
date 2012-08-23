require 'spec_helper'

describe Lender do
  describe 'validations' do
    let(:lender) { FactoryGirl.build(:lender) }

    it 'has a valid factory' do
      lender.should be_valid
    end

    it 'requires a name' do
      lender.name = ''
      lender.should_not be_valid
    end

    it 'requires an organisation_reference_code' do
      lender.organisation_reference_code = ''
      lender.should_not be_valid
    end

    it 'requires high_volume' do
      lender.high_volume = ''
      lender.should_not be_valid
    end

    it 'requires a primary_contact_name' do
      lender.primary_contact_name = ''
      lender.should_not be_valid
    end

    it 'requires a primary_contact_phone' do
      lender.primary_contact_phone = ''
      lender.should_not be_valid
    end

    it 'requires a primary_contact_email' do
      lender.primary_contact_email = ''
      lender.should_not be_valid
    end

    it 'requires can_use_add_cap' do
      lender.can_use_add_cap = ''
      lender.should_not be_valid
    end
  end
end
