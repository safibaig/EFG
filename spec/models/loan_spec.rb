require 'spec_helper'

describe Loan do
  describe 'validations' do
    let(:loan) { FactoryGirl.build(:loan) }

    it 'has a valid Factory' do
      loan.should be_valid
    end

    %w(
      viable_proposition
      would_you_lend
      collateral_exhausted
      amount
      lender_cap
      repayment_duration
      turnover
      trading_date
      sic_code
      loan_category
      reason
      previous_borrowing
      private_residence_charge_required
      personal_guarantee_required
    ).each do |attr|
      it "is invalid without #{attr}" do
        loan[attr] = ''
        loan.should_not be_valid
      end
    end
  end
end
