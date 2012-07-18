require 'spec_helper'

describe LoanTransfer do

  let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :sflg) }

  let(:loan_transfer) {
    FactoryGirl.build(
      :loan_transfer,
      amount: loan.amount,
      new_amount: loan.amount - Money.new(1000),
      reference: loan.reference,
      facility_letter_date: loan.facility_letter_date,
    )
  }

  describe 'validations' do

    it 'should have a valid factory' do
      loan_transfer.should be_valid
    end

    it 'must have a reference' do
      loan_transfer.reference = nil
      loan_transfer.should_not be_valid
    end

    it 'must have an amount' do
      loan_transfer.amount = nil
      loan_transfer.should_not be_valid
    end

    it 'must have a facility letter date' do
      loan_transfer.facility_letter_date = nil
      loan_transfer.should_not be_valid
    end

    it 'must have a new amount' do
      loan_transfer.new_amount = nil
      loan_transfer.should_not be_valid
    end

    it 'declaration signed must be true' do
      loan_transfer.declaration_signed = false
      loan_transfer.should_not be_valid
    end

    it 'declaration signed must not be blank' do
      loan_transfer.declaration_signed = nil
      loan_transfer.should_not be_valid
    end

    it 'must have a lender' do
      loan_transfer.lender = nil
      loan_transfer.should_not be_valid
    end

  end

  describe '#save' do
    let(:original_loan) { loan.reload }

    let(:new_loan) { Loan.last }

    context 'when valid' do
      before(:each) do
        loan_transfer.save
      end

      it 'should transition original loan to repaid from transfer state' do
        original_loan.state.should == Loan::RepaidFromTransfer
      end

      it 'should assign new loan to lender requesting transfer' do
        new_loan.lender.should == loan_transfer.lender
      end

      it "should create new loan with a copy of some of the original loan's data" do
        fields_not_copied = %w(
          id lender_id reference state branch_sortcode repayment_duration amount
          payment_period maturity_date invoice_id generic1 generic2 generic3 generic4
          generic5 transferred_from_id loan_allocation_id created_at updated_at
        )

        fields_to_compare = Loan.column_names - fields_not_copied

        fields_to_compare.each do |field|
          original_loan.send(field).should eql(new_loan.send(field)), "#{field} from transferred loan does not match #{field} from original loan"
        end
      end

      it 'should create new loan with incremented reference number' do
        new_loan.reference.should == LoanReference.new(loan.reference).increment
      end

      it 'should create new loan with state "incomplete"' do
        new_loan.state.should == Loan::Incomplete
      end

      it 'should create new loan with amount set to the specified new amount' do
        new_loan.amount.should == loan_transfer.new_amount
      end

      it 'should create new loan with no value for branch sort code' do
        new_loan.branch_sortcode.should be_blank
      end

      it 'should create new loan with repayment duration of 0' do
        new_loan.repayment_duration.should == MonthDuration.new(0)
      end

      it 'should create new loan with no value for payment period' do
        new_loan.payment_period.should be_blank
      end

      it 'should create new loan with no value for maturity date' do
        new_loan.maturity_date.should be_blank
      end

      it 'should create new loan with no value for generic fields' do
        (1..5).each do |num|
          new_loan.send("generic#{num}").should be_blank
        end
      end

      it 'should create new loan with no invoice' do
        new_loan.invoice_id.should be_blank
      end

      it 'should track which loan a transferred loan came from' do
        new_loan.transferred_from_id.should == loan.id
      end

      it 'should assign new loan to the newest loan allocation of the lender receiving transfer' do
        new_loan.loan_allocation.should == new_loan.lender.loan_allocations.last
      end

      it 'should create new loan with modified by set to user requesting transfer' do
        pending
      end

      it 'should create new loan with created by set to user requesting transfer' do
        pending
      end
    end

    context 'when new loan amount is greater than the amount of the loan being transferred' do
      before(:each) do
        loan_transfer.new_amount = loan.amount + Money.new(100)
      end

      it 'should return false' do
        loan_transfer.save.should == false
      end

      it 'should add error to base' do
        loan_transfer.save
        loan_transfer.errors[:new_amount].should include(error_string('new_amount.cannot_be_greater'))
      end
    end

    context 'when loan being transferred is not in state guaranteed, lender demand or repaid' do
      before(:each) do
        loan.update_attribute(:state, Loan::Eligible)
      end

      it "should return false" do
        loan_transfer.save.should == false
      end
    end

    context 'when loan being transferred belongs to lender requesting the transfer' do
      before(:each) do
        loan_transfer.lender = loan.lender
      end

      it "should return false" do
        loan_transfer.save.should == false
      end

      it "should add error to base" do
        loan_transfer.save
        loan_transfer.errors[:base].should include(error_string('base.cannot_transfer_own_loan'))
      end
    end

    context 'when the loan being transferred has already been transferred' do
      before(:each) do
        # create new loan with same reference of 'loan' but with a incremented version number
        # this means the loan has already been transferred
        loan.update_attribute(:reference, 'QTFDF90+01')
        FactoryGirl.create(:loan, :repaid_from_transfer, reference: 'QTFDF90+02')
      end

      it "should return false" do
        loan_transfer.save.should == false
      end

      it "should add error to base" do
        loan_transfer.save
        loan_transfer.errors[:base].should include(error_string('base.cannot_be_transferred'))
      end
    end

    context 'when no matching loan is found' do
      before(:each) do
        loan_transfer.amount = Money.new(1000)
      end

      it "should return false" do
        loan_transfer.save.should == false
      end

      it "should add error to base" do
        loan_transfer.save
        loan_transfer.errors[:base].should include(error_string('base.cannot_be_transferred'))
      end
    end

    context 'when loan is an EFG loan' do
      before(:each) do
        loan.loan_source = 'S'
        loan.loan_scheme = 'E'
        loan.save
      end

      it "should return false" do
        loan_transfer.save.should == false
      end

      it "should add error to base" do
        loan_transfer.save
        loan_transfer.errors[:base].should include(error_string('base.cannot_be_transferred'))
      end
    end
  end

  private

  def error_string(key)
    I18n.t("activemodel.errors.models.loan_transfer.attributes.#{key}")
  end

end
