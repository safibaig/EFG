require 'spec_helper'

describe LoanTransfer::Sflg do
  let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }
  let!(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :with_state_aid_calculation, :sflg, lender: lender) }
  let(:loan_transfer) {
    FactoryGirl.build(
      :sflg_loan_transfer,
      amount: loan.amount,
      lender: FactoryGirl.create(:lender, :with_lending_limit),
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

  describe "#save" do

    let(:original_loan) { loan.reload }

    let(:new_loan) { Loan.last }

    before(:each) do
      loan_transfer.save
    end

    it "should create new loan with a copy of some of the original loan's data" do
      fields_not_copied = %w(
        id lender_id reference state sortcode repayment_duration amount
        payment_period maturity_date invoice_id generic1 generic2 generic3
        generic4 generic5 transferred_from_id lending_limit_id created_at
        updated_at legacy_id created_by_id
      )

      fields_to_compare = Loan.column_names - fields_not_copied

      fields_to_compare.each do |field|
        original_loan.send(field).should eql(new_loan.send(field)), "#{field} from transferred loan does not match #{field} from original loan"
      end
    end

    it 'should create a new loan state change record for the transferred loan' do
      original_loan.state_changes.count.should == 1

      state_change = original_loan.state_changes.last
      state_change.event_id.should == 15
      state_change.state.should == Loan::RepaidFromTransfer
    end

    it 'should create a new loan state change record for the newly created loan' do
      new_loan.state_changes.count.should == 1

      state_change = new_loan.state_changes.last
      state_change.event_id.should == 15
      state_change.state.should == Loan::Incomplete
    end

  end

end
