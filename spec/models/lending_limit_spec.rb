require 'spec_helper'

describe LendingLimit do

  describe 'validations' do
    let(:lending_limit) { FactoryGirl.build(:lending_limit) }

    it 'has a valid Factory' do
      lending_limit.should be_valid
    end

    it 'requires a lender' do
      lending_limit.lender = nil
      lending_limit.should_not be_valid
    end

    it 'requires an allocation' do
      lending_limit.allocation = nil
      lending_limit.should_not be_valid
    end

    it 'requires a starts_on date' do
      lending_limit.starts_on = nil
      lending_limit.should_not be_valid
    end

    it 'requires a ends_on date' do
      lending_limit.ends_on = nil
      lending_limit.should_not be_valid
    end

    it 'requires a guarantee rate' do
      lending_limit.guarantee_rate = nil
      lending_limit.should_not be_valid
    end

    it 'requires a premium rate' do
      lending_limit.premium_rate = nil
      lending_limit.should_not be_valid
    end

    it 'requires a valid allocation_type_id' do
      lending_limit.allocation_type_id = ''
      lending_limit.should_not be_valid
      lending_limit.allocation_type_id = '99'
      lending_limit.should_not be_valid
      lending_limit.allocation_type_id = '1'
      lending_limit.should be_valid
    end

    it 'requires a name' do
      lending_limit.name = ''
      lending_limit.should_not be_valid
    end

    it 'requires ends_on to be after starts_on' do
      lending_limit.starts_on = Date.new(2012, 1, 2)
      lending_limit.ends_on = Date.new(2012, 1, 1)
      lending_limit.should_not be_valid
    end
  end

  it "has many loans using allocation" do
    lending_limit = FactoryGirl.create(:lending_limit)

    expected_loans = LendingLimit::USAGE_LOAN_STATES.collect do |state|
      FactoryGirl.create(:loan, state: state, lending_limit: lending_limit)
    end

    eligible_loan = FactoryGirl.create(:loan, :eligible, lending_limit: lending_limit)

    lending_limit.loans_using_allocation.should == expected_loans
  end

end
