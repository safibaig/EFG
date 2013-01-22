require 'spec_helper'

describe InvoiceReceivedPresenter do

  describe "validations" do
    let(:invoice_received_presenter) { FactoryGirl.build(:invoice_received_presenter) }

    context "details" do
      it "must have a valid factory" do
        invoice_received_presenter.should be_valid
      end

      it "must have a lender" do
        invoice_received_presenter.lender = nil
        invoice_received_presenter.should_not be_valid
      end

      it "must have a reference" do
        invoice_received_presenter.reference = ''
        invoice_received_presenter.should_not be_valid
      end

      it "must have a period_covered_quarter" do
        invoice_received_presenter.period_covered_quarter = ''
        invoice_received_presenter.should_not be_valid
      end

      it "must have a valid period_covered_quarter" do
        invoice_received_presenter.period_covered_quarter = 'February'
        invoice_received_presenter.should_not be_valid
      end

      it "must have a period_covered_year" do
        invoice_received_presenter.period_covered_year = ''
        invoice_received_presenter.should_not be_valid
      end

      it "must have a valid period_covered_year" do
        invoice_received_presenter.period_covered_year = 'junk'
        invoice_received_presenter.should_not be_valid
      end

      it "must have a valid received_on" do
        invoice_received_presenter.received_on = ''
        invoice_received_presenter.should_not be_valid
      end
    end

    context "save" do
      it "must have some loans" do
        invoice_received_presenter.loans_to_be_settled_ids = []
        invoice_received_presenter.should_not be_valid(:save)
      end

      it "must have a creator" do
        expect {
          invoice_received_presenter.creator = nil
          invoice_received_presenter.valid?(:save)
        }.to raise_error(ActiveModel::StrictValidationFailed)
      end
    end
  end

  describe "#demanded_loans" do
    let(:lender) { FactoryGirl.create(:lender) }
    let!(:demanded_loan_1) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_2) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:settled_loan) { FactoryGirl.create(:loan, :settled, lender: lender) }
    let(:invoice_received_presenter) { FactoryGirl.build(:invoice_received_presenter, lender: lender) }

    it "returns all the demanded loans for the lender" do
      invoice_received_presenter.demanded_loans.should =~ [demanded_loan_1, demanded_loan_2]
    end
  end

  describe "#save" do
    let(:creator) { FactoryGirl.create(:user) }
    let(:lender) { FactoryGirl.create(:lender) }
    let!(:demanded_loan_1) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_2) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let!(:demanded_loan_3) { FactoryGirl.create(:loan, :demanded, lender: lender) }
    let(:invoice_received_presenter) { FactoryGirl.build(:invoice_received_presenter, lender: lender) }

    before do
      invoice_received_presenter.lender = lender
      invoice_received_presenter.reference = 'X123'
      invoice_received_presenter.period_covered_quarter = 'March'
      invoice_received_presenter.period_covered_year = '2012'
      invoice_received_presenter.received_on = '22/01/2013'
      invoice_received_presenter.creator = creator

      invoice_received_presenter.loans_to_be_settled_ids = [demanded_loan_1.id, demanded_loan_2.id]
    end

    it "creates a new invoice" do
      expect {
        invoice_received_presenter.save
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

      invoice_received_presenter.save

      assert_loan_settled = ->(loan) do
        loan.reload

        loan.state.should == Loan::Settled
        loan.settled_on.should == Date.new(2013, 1, 22)
        loan.invoice.should == invoice_received_presenter.invoice
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

    it "logs the loan state changes" do
      expect {
        invoice_received_presenter.save
      }.to change(LoanStateChange, :count).by(2)
    end
  end

  describe "#lender_id" do
    let(:invoice_received_presenter) { FactoryGirl.build(:invoice_received_presenter) }

    it "returns the ID of the lender" do
      lender = FactoryGirl.create(:lender)
      invoice_received_presenter.lender = lender
      invoice_received_presenter.lender_id.should == lender.id
    end

    it "returns nil with no lender" do
      invoice_received_presenter.lender = nil
      invoice_received_presenter.lender_id.should be_nil
    end
  end

  describe "#lender_id=" do
    let(:invoice_received_presenter) { FactoryGirl.build(:invoice_received_presenter) }

    it "sets the lender with the corresponding id" do
      lender = FactoryGirl.create(:lender)

      invoice_received_presenter.lender_id = lender.id
      invoice_received_presenter.lender.should == lender
    end

    it "sets the lender to nil with an incorrect id" do
      invoice_received_presenter.lender_id = 28
      invoice_received_presenter.lender.should be_nil
    end

    it "sets the lender to nil when blank" do
      invoice_received_presenter.lender_id = ''
      invoice_received_presenter.lender.should be_nil
    end
  end

  describe "#received_on=" do
    it "parses dates" do
      presenter = FactoryGirl.build(:invoice_received_presenter)
      presenter.received_on = '22/01/2013'
      presenter.received_on.should == Date.new(2013, 1, 22)
    end
  end

end
