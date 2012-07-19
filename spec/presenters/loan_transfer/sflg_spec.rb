require 'spec_helper'

describe LoanTransfer::Sflg do

  let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :sflg) }

  let(:loan_transfer) {
    FactoryGirl.build(
      :sflg_loan_transfer,
      amount: loan.amount,
      new_amount: loan.amount - Money.new(1000),
      reference: loan.reference,
      facility_letter_date: loan.facility_letter_date,
    )
  }

  it_behaves_like 'a loan transfer'

  describe 'validations' do

    it 'must have a facility letter date' do
      loan_transfer.facility_letter_date = nil
      loan_transfer.should_not be_valid
    end

  end

end
