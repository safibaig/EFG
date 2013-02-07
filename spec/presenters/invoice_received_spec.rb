require 'spec_helper'

describe InvoiceReceived do

  describe "validations" do
    let(:invoice_received) { FactoryGirl.build(:invoice_received) }

    context "details" do
      it "must have a valid factory" do
        invoice_received.should be_valid
      end

      it "must have a lender" do
        invoice_received.lender = nil
        invoice_received.should_not be_valid
      end

      it "must have a reference" do
        invoice_received.reference = ''
        invoice_received.should_not be_valid
      end

      it "must have a period_covered_quarter" do
        invoice_received.period_covered_quarter = ''
        invoice_received.should_not be_valid
      end

      it "must have a valid period_covered_quarter" do
        invoice_received.period_covered_quarter = 'February'
        invoice_received.should_not be_valid
      end

      it "must have a period_covered_year" do
        invoice_received.period_covered_year = ''
        invoice_received.should_not be_valid
      end

      it "must have a valid period_covered_year" do
        invoice_received.period_covered_year = 'junk'
        invoice_received.should_not be_valid
      end

      it "must have a valid received_on" do
        invoice_received.received_on = ''
        invoice_received.should_not be_valid
      end
    end

    context "save" do
      it "must have some loans" do
        invoice_received.loans_attributes = {}
        invoice_received.should_not be_valid(:save)
      end

      it "must have a creator" do
        expect {
          invoice_received.creator = nil
          invoice_received.valid?(:save)
        }.to raise_error(ActiveModel::StrictValidationFailed)
      end
    end
  end

  describe "#loans" do
    let(:lender) { FactoryGirl.create(:lender) }
    let!(:demanded_loan_1) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_2) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:settled_loan) { FactoryGirl.create(:loan, :settled, lender: lender) }
    let(:invoice_received) { FactoryGirl.build(:invoice_received, lender: lender) }

    it "returns SettleLoanRows for the lender's demanded loans" do
      invoice_received.loans.each do |loan|
        loan.should be_instance_of(SettleLoan)
      end

      invoice_received.loans.map(&:loan).should =~ [demanded_loan_1, demanded_loan_2]
    end
  end

  describe "#save" do
    let(:creator) { FactoryGirl.create(:user) }
    let(:lender) { FactoryGirl.create(:lender) }
    let!(:demanded_loan_1) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_2) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_3) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let(:invoice_received) { FactoryGirl.build(:invoice_received, lender: lender) }

    before do
      invoice_received.lender = lender
      invoice_received.reference = 'X123'
      invoice_received.period_covered_quarter = 'March'
      invoice_received.period_covered_year = '2012'
      invoice_received.received_on = '22/01/2013'
      invoice_received.creator = creator

      invoice_received.loans_attributes = {
        '0' => {
          'id' => demanded_loan_1.id.to_s,
          'settled' => '1',
          'settled_amount' => '340.12'
        },
        '1' => {
          'id' => demanded_loan_2.id.to_s,
          'settled' => '1',
          'settled_amount' => '6234.45'
        },
        '2' => {
          'id' => demanded_loan_3.id.to_s,
          'settled' => '0'
        }
      }
    end

    it "creates a new invoice" do
      expect {
        invoice_received.save
      }.to change(Invoice, :count).by(1)

      invoice = Invoice.last
      invoice.lender.should == lender
      invoice.reference.should == 'X123'
      invoice.period_covered_quarter.should == 'March'
      invoice.period_covered_year.should == '2012'
      invoice.received_on.should == Date.new(2013, 1, 22)
      invoice.created_by = creator
    end

    it "marks the selected loans as Settled" do
      Timecop.freeze(2013, 1, 22, 11, 49)

      invoice_received.save

      assert_loan_settled = ->(loan) do
        loan.reload

        loan.state.should == Loan::Settled
        loan.settled_on.should == Date.new(2013, 1, 22)
        loan.invoice.should == invoice_received.invoice
        loan.updated_at.should == Time.new(2013, 1, 22, 11, 49, 0)
        loan.modified_by_id.should == creator.id
      end

      assert_loan_settled.call(demanded_loan_1)
      assert_loan_settled.call(demanded_loan_2)

      demanded_loan_3.reload
      demanded_loan_3.state.should == Loan::Demanded
      demanded_loan_3.settled_on.should be_nil
      demanded_loan_3.invoice.should be_nil

      Timecop.return
    end

    it "updates the settled amount" do
      invoice_received.save

      demanded_loan_1.reload
      demanded_loan_1.settled_amount.should == Money.new(340_12)

      demanded_loan_2.reload
      demanded_loan_2.settled_amount.should == Money.new(6234_45)
    end

    it "logs the loan state changes" do
      expect {
        invoice_received.save
      }.to change(LoanStateChange, :count).by(2)
    end
  end

  describe "#lender_id" do
    let(:invoice_received) { FactoryGirl.build(:invoice_received) }

    it "returns the ID of the lender" do
      lender = FactoryGirl.create(:lender)
      invoice_received.lender = lender
      invoice_received.lender_id.should == lender.id
    end

    it "returns nil with no lender" do
      invoice_received.lender = nil
      invoice_received.lender_id.should be_nil
    end
  end

  describe "#lender_id=" do
    let(:invoice_received) { FactoryGirl.build(:invoice_received) }

    it "sets the lender with the corresponding id" do
      lender = FactoryGirl.create(:lender)

      invoice_received.lender_id = lender.id
      invoice_received.lender.should == lender
    end

    it "sets the lender to nil with an incorrect id" do
      invoice_received.lender_id = 28
      invoice_received.lender.should be_nil
    end

    it "sets the lender to nil when blank" do
      invoice_received.lender_id = ''
      invoice_received.lender.should be_nil
    end
  end

  describe "#received_on=" do
    it "parses dates" do
      presenter = FactoryGirl.build(:invoice_received)
      presenter.received_on = '22/01/2013'
      presenter.received_on.should == Date.new(2013, 1, 22)
    end
  end

end
