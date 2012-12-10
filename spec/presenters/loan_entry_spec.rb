# encoding: utf-8
require 'spec_helper'

describe LoanEntry do

  let(:loan_entry) { FactoryGirl.build(:loan_entry) }

  before(:each) do
    # ensure recalculate state aid validation does not fail
    Loan.any_instance.stub(:repayment_duration_changed?).and_return(false)
  end

  describe "validations" do
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
      loan_entry.loan.state_aid_calculations.delete_all
      loan_entry.should_not be_valid
      loan_entry.errors[:state_aid].should == ['must be calculated']
    end

    it "should be invalid when turnover is greater than £41,000,000" do
      loan_entry.turnover = Money.new(41_000_000_01)
      loan_entry.should_not be_valid
    end

    LegalForm.all.select { |l| l.requires_company_registration == true }.each do |legal_form|
      context "when legal_form is #{legal_form.name}" do
        it "should be invalid without company registration number" do
          loan_entry.legal_form_id = legal_form.id
          loan_entry.should_not be_valid
          loan_entry.company_registration = "B1234567890"
          loan_entry.should be_valid
        end
      end
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

      it "should require security proportion greater than 0" do
        loan_entry.security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require security proportion less than 100" do
        loan_entry.security_proportion = 100
        loan_entry.should_not be_valid
      end
    end

    context 'when a type C loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_c) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require original overdraft proportion greater than 0" do
        loan_entry.original_overdraft_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require original overdraft proportion less than 100" do
        loan_entry.original_overdraft_proportion = 100
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion greater than 0" do
        loan_entry.refinance_security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion less than or equal to 100" do
        loan_entry.refinance_security_proportion = 100.1
        loan_entry.should_not be_valid
      end
    end

    context 'when a type D loan' do
      let(:loan_entry) { FactoryGirl.build(:loan_entry_type_d) }

      it "should have a valid factory" do
        loan_entry.should be_valid
      end

      it "should require refinance security proportion greater than 0" do
        loan_entry.refinance_security_proportion = 0.0
        loan_entry.should_not be_valid
      end

      it "should require refinance security proportion less than or equal to 100" do
        loan_entry.refinance_security_proportion = 100.1
        loan_entry.should_not be_valid
      end

      it "should require current refinanced value" do
        loan_entry.current_refinanced_amount = nil
        loan_entry.should_not be_valid
      end

      it "should require final refinanced value" do
        loan_entry.final_refinanced_amount = nil
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

      it "should require debtor book coverage greater than or equal to 1" do
        loan_entry.debtor_book_coverage = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book coverage less than 100" do
        loan_entry.debtor_book_coverage = 100
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup greater than or equal to 1" do
        loan_entry.debtor_book_topup = 0.9
        loan_entry.should_not be_valid
      end

      it "should require debtor book topup less than or equal to 30" do
        loan_entry.debtor_book_topup = 30.1
        loan_entry.should_not be_valid
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

    it_behaves_like 'loan presenter that validates loan repayment frequency' do
      let(:loan_presenter) { loan_entry }
    end
  end

  describe "#save" do
    context "when loan is no longer eligible" do
      before do
        loan_entry.viable_proposition = false
      end

      it "should set state to 'incomplete'" do
        expect {
          loan_entry.save
        }.to change(loan_entry.loan, :state).to(Loan::Incomplete)
      end

      it "should save ineligibility reasons" do
        expect {
          loan_entry.save
        }.to change(loan_entry.loan.ineligibility_reasons, :count).by(1)
      end
    end
  end
end
