require 'spec_helper'

describe LoanEligibilityCheck do
  describe 'validations' do
    let(:loan_eligibility_check) { FactoryGirl.build(:loan_eligibility_check) }

    it 'has a valid factory' do
      loan_eligibility_check.should be_valid
    end

    %w(
      amount
      lender_cap_id
      repayment_duration
      turnover
      trading_date
      sic_code
      loan_category_id
      reason_id
    ).each do |attr|
      it "is invalid without #{attr}" do
        loan_eligibility_check.send("#{attr}=", '')
        loan_eligibility_check.should_not be_valid
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
          loan_eligibility_check.send("#{attr}=", true)
          loan_eligibility_check.should be_valid
        end

        it "is valid with false" do
          loan_eligibility_check.send("#{attr}=", false)
          loan_eligibility_check.should be_valid
        end

        it "is invalid with nil" do
          loan_eligibility_check.send("#{attr}=", nil)
          loan_eligibility_check.should be_invalid
        end
      end
    end

    describe '#amount' do
      it 'is invalid when less than zero' do
        loan_eligibility_check.amount = -1
        loan_eligibility_check.should be_invalid
      end

      it 'is invalid when zero' do
        loan_eligibility_check.amount = 0
        loan_eligibility_check.should be_invalid
      end
    end

    describe '#repayment_duration' do
      it 'is invalid when zero' do
        loan_eligibility_check.repayment_duration = { years: 0, months: 0}
        loan_eligibility_check.should be_invalid
      end

      it 'is valid when greater than zero' do
        loan_eligibility_check.repayment_duration = { months: 1 }
        loan_eligibility_check.should be_valid
      end
    end
  end

  describe '#save' do
    let(:lender) { FactoryGirl.create(:lender) }

    it 'assigns the specified lender to the created loan' do
      loan_eligibility_check = LoanEligibilityCheck.new(lender.loans.new)

      attributes = FactoryGirl.attributes_for(:loan_eligibility_check)
      loan_eligibility_check.attributes = attributes

      expect {
        loan_eligibility_check.save
      }.to change(Loan, :count).by(1)

      Loan.last.lender.should == lender
    end
  end
end
