require 'spec_helper'

describe LoanTransfer do

  let(:loan_transfer) { FactoryGirl.build(:loan_transfer) }

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

  end

  describe "#valid_loan_transfer_request?" do
    let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed) }

    let(:loan_transfer) {
      FactoryGirl.build(
        :loan_transfer,
        amount: loan.amount.to_f,
        new_amount: (loan.amount - Money.new(1000_00)).to_f,
        reference: loan.reference,
        facility_letter_date: loan.facility_letter_date.strftime('%d/%m/%Y'),
      )
    }

    it "should return true when all attributes are valid and a loan that matches the specified loan transfer is found" do
      loan_transfer.should be_valid_loan_transfer_request
    end

    it "should return false when not all attributes are valid" do
      loan_transfer.reference = nil
      loan_transfer.should_not be_valid_loan_transfer_request
    end

    context 'when no matching loan is found' do
      before(:each) do
        loan_transfer.reference = "wrong"
      end

      it "should return false" do
        loan_transfer.should_not be_valid_loan_transfer_request
      end

      it "should add error to base" do
        loan_transfer.valid_loan_transfer_request?
        loan_transfer.errors[:base].should_not be_empty
      end
    end

  end

end
