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

  describe "#save" do

    let(:original_loan) { loan.reload }

    let(:new_loan) { Loan.last }

    before(:each) do
      loan_transfer.save
    end

    it "should clear state aid value" do
      new_loan.state_aid.should be_blank
    end

    it "should set state aid to be valid" do
      new_loan.state_aid_is_valid.should be_true
    end

    it "should set notified aid to false" do
      new_loan.notified_aid.should be_false
    end

    it "should set declaration signed to true" do
      new_loan.declaration_signed.should be_true
    end

    it "should set viable proposition to true" do
      new_loan.viable_proposition.should be_true
    end

    it "should set collateral exhausted to true" do
      new_loan.collateral_exhausted.should be_true
    end

    it "should set previous borrowing to true" do
      new_loan.previous_borrowing.should be_true
    end

    it "should clear facility letter date" do
      new_loan.facility_letter_date.should be_nil
    end

    it "should set would you lend to true" do
      new_loan.would_you_lend.should be_true
    end

    it "should create new loan with a copy of some of the original loan's data" do
      fields_not_copied = %w(
        id lender_id reference state branch_sortcode repayment_duration amount
        payment_period maturity_date invoice_id generic1 generic2 generic3 generic4
        generic5 transferred_from_id loan_allocation_id created_at updated_at
        facility_letter_date declaration_signed state_aid state_aid_is_valid
        notified_aid viable_proposition collateral_exhausted previous_borrowing
        would_you_lend legacy_id
      )

      fields_to_compare = Loan.column_names - fields_not_copied

      fields_to_compare.each do |field|
        original_loan.send(field).should eql(new_loan.send(field)), "#{field} from transferred loan does not match #{field} from original loan"
      end
    end

  end

end