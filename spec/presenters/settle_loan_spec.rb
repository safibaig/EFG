require 'spec_helper'

describe SettleLoan do

  describe "validations" do
    let(:loan) { FactoryGirl.create(:loan, :demanded) }
    let(:presenter) { SettleLoan.new(loan) }

    it "must have a settled_amount" do
      presenter.settled_amount = nil
      presenter.should_not be_valid
    end

    it "must have a settled_amount greater than or equal to 0" do
      presenter.settled_amount = Money.new(-1)
      presenter.should_not be_valid

      presenter.settled_amount = Money.new(0)
      presenter.should be_valid
    end

    it "must have a settled_amount less than or equal to the claimed amount" do
      loan.dti_amount_claimed = Money.new(4824_95)

      presenter.settled_amount = Money.new(4824_96)
      presenter.should_not be_valid

      presenter.settled_amount = Money.new(4824_95)
      presenter.should be_valid
    end
  end

  describe "attributes" do
    let(:loan) { FactoryGirl.build(:loan, :demanded) }
    let(:presenter) { SettleLoan.new(loan) }

    it "delegates id" do
      presenter.id.should == loan.id
    end

    it "delegates business name" do
      presenter.business_name.should == loan.business_name
    end

    it "delegates corrected?" do
      presenter.corrected?.should == loan.corrected?
    end

    it "delegates dti_amount_claimed" do
      presenter.dti_amount_claimed.should == loan.dti_amount_claimed
    end

    it "delegates dti_demanded_on" do
      presenter.dti_demanded_on.should == loan.dti_demanded_on
    end

    it "delegates reference" do
      presenter.reference.should == loan.reference
    end
  end

  describe "#settled?" do
    let(:loan) { FactoryGirl.build(:loan, :demanded) }
    let(:presenter) { SettleLoan.new(loan) }

    it "is false by default" do
      presenter.should_not be_settled
    end

    it "can be set" do
      presenter.settled = true
      presenter.should be_settled
    end
  end

  describe "#settled_amount" do
    let(:loan) { FactoryGirl.build(:loan, :demanded, dti_amount_claimed: Money.new(15_594_80)) }
    let(:presenter) { SettleLoan.new(loan) }

    it "defaults to the dti_claimed_amount" do
      presenter.settled_amount.should == Money.new(15_594_80)
    end

    it "can be set" do
      presenter.settled_amount = '10,000.00'
      presenter.settled_amount.should == Money.new(10_000_00)
    end
  end

  describe "settle!" do
    let(:creator) { FactoryGirl.create(:user) }
    let(:invoice) { FactoryGirl.create(:invoice) }
    let(:loan) { FactoryGirl.create(:loan, :demanded) }

    context "marked as settled" do
      let(:presenter) do
        presenter = SettleLoan.new(loan)
        presenter.settled = true
        presenter.settled_amount = Money.new(340_12)
        presenter
      end

      it "transitions the loan to Settled" do
        Timecop.freeze(2013, 1, 22, 11, 49) do
          presenter.settled = true
          presenter.settle!(invoice, creator)

          loan.reload

          loan.state.should == Loan::Settled
          loan.settled_on.should == Date.new(2013, 1, 22)
          loan.invoice.should == invoice
          loan.updated_at.should == Time.new(2013, 1, 22, 11, 49, 0)
          loan.modified_by_id.should == creator.id
        end
      end

      it "updates the settled amount" do
        presenter.settle!(invoice, creator)

        loan.reload
        loan.settled_amount.should == Money.new(340_12)
      end

      it "logs the loan state changes" do
        expect {
          presenter.settle!(invoice, creator)
        }.to change(LoanStateChange, :count).by(1)
      end
    end

    context "not marked as settled" do
      let(:presenter) do
        presenter = SettleLoan.new(loan)
        presenter.settled = false
        presenter
      end

      it "raises an NotMarkedAsSettled exception" do
        presenter.should_not be_settled
        expect {
          presenter.settle!(invoice, creator)
        }.to raise_error(SettleLoan::NotMarkedAsSettled)
      end
    end
  end
end
