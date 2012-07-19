require 'spec_helper'

describe LoanTransfer::LegacySflg do

  let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :legacy_sflg) }

  let(:loan_transfer) {
    FactoryGirl.build(
      :legacy_sflg_loan_transfer,
      amount: loan.amount,
      new_amount: loan.amount - Money.new(1000),
      reference: loan.reference,
      initial_draw_date: loan.initial_draw_date,
    )
  }

  it_behaves_like 'a loan transfer'

  describe 'validations' do

    it 'must have an initial draw date' do
      loan_transfer.initial_draw_date = nil
      loan_transfer.should_not be_valid
    end

  end

end
