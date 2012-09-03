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

  describe 'current lending limits' do
    let(:lender) { FactoryGirl.create(:lender) }

    before do
      FactoryGirl.create(:lending_limit, lender: lender, allocation: Money.new(1_000_00), allocation_type_id: 1)
      FactoryGirl.create(:lending_limit, lender: lender, allocation: Money.new(2_000_00), allocation_type_id: 1, active: false)
      FactoryGirl.create(:lending_limit, lender: lender, allocation: Money.new(4_000_00), allocation_type_id: 2)
      FactoryGirl.create(:lending_limit, lender: lender, allocation: Money.new(8_000_00), allocation_type_id: 1)
      FactoryGirl.create(:lending_limit, lender: lender, allocation: Money.new(16_000_00), allocation_type_id: 1, starts_on: 2.months.ago, ends_on: 1.month.ago)
    end

    it do
      lender.current_annual_lending_limit_allocation.should == Money.new(9_000_00)
    end

    it do
      lender.current_specific_lending_limit_allocation.should == Money.new(4_000_00)
    end
  end
end
