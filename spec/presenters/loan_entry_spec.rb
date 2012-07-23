require 'spec_helper'

describe LoanEntry do
  before(:each) do
    # ensure recalculate state aid validation does not fail
    Loan.any_instance.stub(:repayment_duration_changed?).and_return(false)
  end

  describe "validations" do
    let(:loan_entry) { FactoryGirl.build(:loan_entry) }

    it "should have a valid factory" do
      loan_entry.should be_valid
    end

    it "should be invalid if the declaration hasn't been signed" do
      loan_entry.declaration_signed = false
      loan_entry.should_not be_valid
    end

    it "should be invalid if interest rate type isn't selected" do
      loan_entry.interest_rate_type_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business name" do
      loan_entry.business_name = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a business type" do
      loan_entry.legal_form_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a postcode" do
      loan_entry.postcode = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment frequency" do
      loan_entry.repayment_frequency_id = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without a maturity date" do
      loan_entry.maturity_date = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without an interest rate" do
      loan_entry.interest_rate = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a repayment duration" do
      loan_entry.repayment_duration = nil
      loan_entry.should_not be_valid
    end

    it "should be invalid without fees" do
      loan_entry.fees = ''
      loan_entry.should_not be_valid
    end

    it "should be invalid without a state aid calculation" do
      loan_entry.loan.state_aid_calculation = nil
      loan_entry.should_not be_valid
      loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    context 'when a type B loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_b) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require security types" do
        loan_entry.loan.loan_securities.clear
        loan_entry.should_not be_valid
      end

      it "should require security proportion" do
        loan_entry.security_proportion = nil
        loan_entry.should_not be_valid
      end
    end

    context 'when a type C loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_c) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require original overdraft proportion" do
        loan_entry.original_overdraft_proportion = nil
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion" do
        loan_entry.refinance_security_proportion = nil
        loan_entry.should_not be_valid
      end
    end

    context 'when a type D loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_d) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require refinance security proportion" do
        loan_entry.refinance_security_proportion = nil
        loan_entry.should_not be_valid
      end

      it "should require current refinanced value" do
        loan_entry.current_refinanced_value = nil
        loan_entry.should_not be_valid
      end

      it "should require final refinanced value" do
        loan_entry.final_refinanced_value = nil
        loan_entry.should_not be_valid
      end
    end

    context 'when a type E loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_e) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require overdraft limit" do
        loan_entry.overdraft_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require overdraft maintained" do
        loan_entry.overdraft_maintained = false
        loan_entry.should_not be_valid
      end

      it "should have a maximum repayment duration of 2 years" do
        loan_entry.repayment_duration = 25
        loan_entry.should_not be_valid

        loan_entry.repayment_duration = 24
        loan_entry.should be_valid
      end
    end

    context 'when a type F loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_f) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require invoice discount limit" do
        loan_entry.invoice_discount_limit = nil
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage" do
        loan_entry.debtor_book_coverage = nil
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup" do
        loan_entry.debtor_book_topup = nil
        loan_entry.should_not be_valid
      end

      it "should have a maximum repayment duration of 3 years" do
        loan_entry.repayment_duration = 37
        loan_entry.should_not be_valid

        loan_entry.repayment_duration = 36
        loan_entry.should be_valid
      end
    end

    context "when repayment duration is changed" do
      before(:each) do
        # ensure recalculate state aid validation fails
        Loan.any_instance.stub(:repayment_duration_changed?).and_return(true)
      end

      it "should require a recalculation of state aid" do
        loan_entry.should_not be_valid
        loan_entry.should have(1).error_on(:state_aid)
      end
    end

    # Although a business may benefit from EFG on more than one occasion, and may have more than one EFG-backed facility at any one time, the total outstanding balances and/or active available limits of the Applicant's current EFG facilities may not exceed £1 million at any one time.
    # To be eligible for EFG the Applicant's De Minimis State Aid status must be checked to ensure that it does not exceed the €200,000 rolling three year limit (or the corresponding lower limit applicable in certain business sectors). On this occasion that check has not been performed.
  end
end
