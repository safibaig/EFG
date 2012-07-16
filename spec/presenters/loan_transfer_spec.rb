require 'spec_helper'

describe LoanTransfer do

  let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed) }

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

    context 'when new loan amount is greater than the amount of the loan being transferred' do
      before(:each) do
        loan_transfer.new_amount = loan.amount + Money.new(100)
      end

      it 'should return false' do
        loan_transfer.should_not be_valid
      end

      it 'should add error to base' do
        loan_transfer.valid?
        loan_transfer.errors[:new_amount].should include('cannot be greater than the amount of the loan being transferred')
      end
    end

    context 'when loan being transferred is not in state guaranteed, lender demand or repaid' do
      before(:each) do
        loan.update_attribute(:state, Loan::Eligible)
      end

      it "should return false" do
        loan_transfer.should_not be_valid
      end
    end

    context 'when loan being transferred belongs to lender requesting the transfer' do
      before(:each) do
        loan_transfer.lender = loan.lender
      end

      it "should return false" do
        loan_transfer.should_not be_valid
      end

      it "should add error to base" do
        loan_transfer.valid?
        loan_transfer.errors[:base].should include('You cannot transfer one of your own loans')
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
        loan_transfer.should_not be_valid
      end

      it "should add error to base" do
        loan_transfer.valid?
        loan_transfer.errors[:base].should include('The specified loan cannot be transferred')
      end
    end

    context 'when no matching loan is found' do
      before(:each) do
        loan_transfer.amount = Money.new(1000)
      end

      it "should return false" do
        loan_transfer.should_not be_valid
      end

      it "should add error to base" do
        loan_transfer.valid?
        loan_transfer.errors[:base].should include('Could not find the specified loan, please check the data you have entered')
      end
    end

  end

  describe '#transfer!' do
    let(:original_loan) { loan.reload }

    let(:new_loan) { Loan.last }

    before(:each) do
      loan_transfer.transfer!
    end

    it 'should transition original loan to repaid from transfer state' do
      original_loan.state.should == Loan::RepaidFromTransfer
    end

    it 'should assign new loan to lender requesting transfer' do
      new_loan.lender.should == loan_transfer.lender
    end

    it "should create new loan with a copy of some of the original loan's data" do
      fields_not_copied = %w(
        id lender_id reference state branch_sortcode repayment_duration
        payment_period maturity_date invoice_id generic1 generic2 generic3 generic4 generic5
      )

      fields_to_compare = Loan.column_names - fields_not_copied

      fields_to_compare.each do |field|
        original_loan.send(field).should == new_loan.send(field)
      end
    end

    it 'should create new loan with incremented reference number' do
      new_loan.reference.should == LoanReference.new(loan.reference).increment
    end

    it 'should create new loan with state "incomplete"' do
      new_loan.state.should == Loan::Incomplete
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

    it 'should create new loan with modified by set to user requesting transfer' do
      pending
    end

    it 'should create new loan with created by set to user requesting transfer' do
      pending
    end
  end

end
