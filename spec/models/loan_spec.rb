require 'spec_helper'

describe Loan do
  describe 'validations' do
    let(:loan) { FactoryGirl.build(:loan) }

    it 'has a valid Factory' do
      loan.should be_valid
    end

    %w(
      amount
      lender_cap
      repayment_duration
      turnover
      trading_date
      sic_code
      loan_category
      reason
    ).each do |attr|
      it "is invalid without #{attr}" do
        loan[attr] = ''
        loan.should_not be_valid
      end
    end

    %w(
      viable_proposition
      would_you_lend
      collateral_exhausted
      previous_borrowing
      private_residence_charge_required
      personal_guarantee_required
    ).each do |attr|
      describe "boolean value: #{attr}" do
        it "is valid with true" do
          loan[attr] = true
          loan.should be_valid
        end

        it "is valid with false" do
          loan[attr] = false
          loan.should be_valid
        end

        it "is invalid with nil" do
          loan[attr] = nil
          loan.should be_invalid
        end
      end
    end
  end
end
