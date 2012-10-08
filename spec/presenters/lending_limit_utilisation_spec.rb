# encoding: utf-8

require 'spec_helper'

describe LendingLimitUtilisation do
  let(:lender) { FactoryGirl.create(:lender) }
  let(:lending_limit) { FactoryGirl.create(:lending_limit, allocation: Money.new(2_000_000_00)) }

  let!(:loan1) { FactoryGirl.create(:loan, :guaranteed, lender: lender, lending_limit: lending_limit, amount: Money.new(200_000_00)) }
  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed, lender: lender, lending_limit: lending_limit, amount: Money.new(400_000_00)) }
  let!(:loan3) { FactoryGirl.create(:loan, :demanded,   lender: lender, lending_limit: lending_limit, amount: Money.new(500_000_00), amount_demanded: Money.new(99_234_56)) }
  let!(:loan4) { FactoryGirl.create(:loan, :settled,    lender: lender, lending_limit: lending_limit, amount: Money.new(750_000_00), amount_demanded: Money.new(78_890_12)) }

  let!(:recovery) { FactoryGirl.create(:recovery, loan: loan4, amount_due_to_dti: Money.new(53_789_12)) }

  let(:presenter) { LendingLimitUtilisation.new(lending_limit) }

  let(:presenter_with_no_loans) {
    LendingLimitUtilisation.new(LendingLimit.new)
  }

  describe '#cumulative_claims' do
    it 'with claimed loans' do
      presenter.cumulative_claims.should == Money.new(178_124_68)
    end

    it 'with no loans' do
      presenter_with_no_loans.cumulative_claims.should == Money.new(0)
    end
  end

  describe '#cumulative_net_claims' do
    it do
      presenter.cumulative_net_claims.should == Money.new(124_335_56)
    end

    it 'with no loans' do
      presenter_with_no_loans.cumulative_net_claims.should == Money.new(0)
    end
  end

  describe "#usage_amount" do
    it "should return sum of all loan amounts" do
      presenter.usage_amount.should == Money.new(1_850_000_00)
    end

    it "should return 0 when allocation has no loans" do
      presenter_with_no_loans.usage_amount.should == Money.new(0)
    end
  end

  describe '#gross_utilisation_of_claim_limit' do
    context 'with no loans' do
      it do
        presenter_with_no_loans.gross_utilisation_of_claim_limit.should == '0.00%'
      end
    end

    context 'with a usage_amount < £1 million' do
      before do
        Loan.where(id: [loan2.id, loan3.id]).delete_all
      end

      it do
        presenter.gross_utilisation_of_claim_limit.should == '55.36%'
      end
    end

    context 'with a usage_amount > £1 million' do
      it do
        presenter.gross_utilisation_of_claim_limit.should == '77.98%'
      end
    end
  end

  describe '#net_utilisation_of_claim_limit' do
    context 'with no loans' do
      it do
        presenter_with_no_loans.net_utilisation_of_claim_limit.should == '0.00%'
      end
    end

    context 'with a usage_amount < £1 million' do
      before do
        Loan.where(id: [loan2.id, loan3.id]).delete_all
      end

      it do
        presenter.net_utilisation_of_claim_limit.should == '17.61%'
      end
    end

    context 'with a usage_amount > £1 million' do
      it do
        presenter.net_utilisation_of_claim_limit.should == '54.43%'
      end
    end
  end

  describe "#usage_percentage" do
    it "should return percentage of total allocation used" do
      presenter.usage_percentage.should == '92.50%'
    end

    it "should return 0 when allocation has no loans" do
      presenter_with_no_loans.usage_percentage.should == '0.00%'
    end
  end
end
