require 'spec_helper'

describe LoanDemandAgainstGovernment do

  let(:loan_demand_against_government) { FactoryGirl.build(:loan_demand_against_government) }

  let(:loan) { loan_demand_against_government.loan }

  describe 'validations' do

    it 'should have a valid factory' do
      loan_demand_against_government.should be_valid
    end

    it 'should be invalid without dti demanded oustanding' do
      loan_demand_against_government.dti_demand_outstanding = nil
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without a demanded date' do
      loan_demand_against_government.dti_demanded_on = ''
      loan_demand_against_government.should_not be_valid
    end

    it 'should be invalid without a DED code' do
      loan_demand_against_government.dti_ded_code = ''
      loan_demand_against_government.should_not be_valid
    end

    it "should be invalid when demanded date is before demand to borrower date" do
      loan_demand_against_government.dti_demanded_on = loan.borrower_demanded_on - 1.day
      loan_demand_against_government.should_not be_valid

      loan_demand_against_government.dti_demanded_on = loan.borrower_demanded_on
      loan_demand_against_government.should be_valid
    end

    %w(sflg legacy_sflg).each do |loan_type|
      context "when #{loan_type} loan" do
        let(:loan_demand_against_government) { FactoryGirl.build("#{loan_type}_loan_demand_against_government") }

        it "should be invalid without dti_interest" do
          loan_demand_against_government.dti_interest = nil
          loan_demand_against_government.should_not be_valid
        end

        it "should be invalid without dti_break_costs" do
          loan_demand_against_government.dti_break_costs = nil
          loan_demand_against_government.should_not be_valid
        end
      end
    end
  end

  describe "#dti_amount_claimed" do
    it "should be set when record is saved" do
      loan_demand_against_government.dti_amount_claimed.should be_blank
      loan_demand_against_government.save
      loan_demand_against_government.dti_amount_claimed.should == Money.new(7500_00) # 75% of £10,000
    end
  end
end
