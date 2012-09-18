require 'spec_helper'

describe LoanNoClaim do
  describe 'validations' do
    let(:loan_no_claim) { FactoryGirl.build(:loan_no_claim) }
    let(:loan) { loan_no_claim.loan }

    it 'should have a valid factory' do
      loan_no_claim.should be_valid
    end

    it 'should be invalid without a no_claim date' do
      loan_no_claim.no_claim_on = ''
      loan_no_claim.should_not be_valid
    end

    it 'must have a no_claim_on gte last demand to borrower' do
      loan.borrower_demanded_on = Date.new(2012, 6, 6)
      loan.save!

      loan_no_claim.no_claim_on = Date.new(2012, 6, 5)
      loan_no_claim.should_not be_valid
    end
  end
end
