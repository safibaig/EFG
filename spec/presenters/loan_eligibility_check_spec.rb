require 'spec_helper'

describe LoanEligibilityCheck do
  describe 'validations' do
    let(:loan_eligibility_check) { FactoryGirl.build(:loan_eligibility_check) }

    it 'has a valid factory' do
      loan_eligibility_check.should be_valid
    end

    %w(
      amount
      repayment_duration
      loan_allocation_id
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

    describe '#loan_scheme' do
      it 'is invalid when not "E"' do
        loan_eligibility_check.loan_scheme = Loan::SFLG_SCHEME
        loan_eligibility_check.should be_invalid
      end

      it 'is valid when "E"' do
        loan_eligibility_check.loan_scheme = Loan::EFG_SCHEME
        loan_eligibility_check.should be_valid
      end
    end

    describe '#loan_source' do
      it 'is invalid when not "S"' do
        loan_eligibility_check.loan_source = Loan::LEGACY_SFLG_SOURCE
        loan_eligibility_check.should be_invalid
      end

      it 'is valid when "S"' do
        loan_eligibility_check.loan_source = Loan::SFLG_SOURCE
        loan_eligibility_check.should be_valid
      end
    end
  end

  describe '#save' do
    let(:loan_eligibility_check) { FactoryGirl.build(:loan_eligibility_check) }

    it "should set the state to Eligible if its eligible" do
      EligibilityCheck.any_instance.stub(:eligible?).and_return(true)

      loan_eligibility_check.save
      loan_eligibility_check.loan.state.should == Loan::Eligible
    end

    it "should set the state to Rejected if its not eligible" do
      EligibilityCheck.any_instance.stub(:eligible?).and_return(false)
      EligibilityCheck.any_instance.stub(:reasons).and_return([ "Reason 1", "Reason 2" ])

      loan_eligibility_check.save
      loan_eligibility_check.loan.state.should == Loan::Rejected
    end

    it "should create rejected loan state change if its not eligible" do
      EligibilityCheck.any_instance.stub(:eligible?).and_return(false)
      EligibilityCheck.any_instance.stub(:reasons).and_return([ "Reason 1", "Reason 2" ])

      expect {
        loan_eligibility_check.save
      }.to change(LoanStateChange, :count).by(1)

      LoanStateChange.last.event.should == LoanEvent.find(0)
    end

    it "should create accepted loan state change if its eligible" do
      EligibilityCheck.any_instance.stub(:eligible?).and_return(true)

      expect {
        loan_eligibility_check.save
      }.to change(LoanStateChange, :count).by(1)

      LoanStateChange.last.event.should == LoanEvent.find(1)
    end

    it "should create loan ineligibility record if its not eligible" do
      EligibilityCheck.any_instance.stub(:eligible?).and_return(false)
      EligibilityCheck.any_instance.stub(:reasons).and_return([ "Reason 1", "Reason 2" ])

      expect {
        loan_eligibility_check.save
      }.to change(LoanIneligibilityReason, :count).by(1)

      LoanIneligibilityReason.last.reason.should == "Reason 1\nReason 2"
    end
  end
end
