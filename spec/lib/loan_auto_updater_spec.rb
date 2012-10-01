require 'spec_helper'
require 'loan_auto_updater'

describe LoanAutoUpdater do

  shared_examples_for "auto-updated loan" do
    it "should create LoanStateChange record for expired loans" do
      expect {
        dispatch
      }.to change(LoanStateChange, :count).by(1)

      LoanStateChange.last.loan.should == expired_loan
    end
  end

  let!(:system_user) { FactoryGirl.create(:system_user) }

  describe ".cancel_not_progressed_loans!" do
    let!(:expired_loan) { FactoryGirl.create(:loan, :eligible, updated_at: 6.months.ago.advance(days: -1)) }
    let!(:unexpired_loan) { FactoryGirl.create(:loan, :eligible, updated_at: 6.months.ago) }

    def dispatch
      LoanAutoUpdater.cancel_not_progressed_loans!
    end

    it "should update state of loans last updated more than 6 months ago to auto-cancelled" do
      dispatch

      expired_loan.reload.state.should == Loan::AutoCancelled
      unexpired_loan.reload.state.should == Loan::Eligible
    end

    it_behaves_like "auto-updated loan"
  end

  describe ".cancel_not_drawn_loans!" do
    let!(:expired_loan) { FactoryGirl.create(:loan, :offered, facility_letter_date: 6.months.ago.advance(days: -11)) }
    let!(:unexpired_loan) { FactoryGirl.create(:loan, :offered, facility_letter_date: 6.months.ago.advance(days: -10)) }

    def dispatch
      LoanAutoUpdater.cancel_not_drawn_loans!
    end

    it "should update state of loans with a facility letter date older than 6 months to auto-cancelled" do
      dispatch

      expired_loan.reload.state.should == Loan::AutoCancelled
      unexpired_loan.reload.state.should == Loan::Offered
    end

    it_behaves_like "auto-updated loan"
  end

  describe ".remove_guarantee_from_not_demanded_loans!" do

    def dispatch
      LoanAutoUpdater.remove_guarantee_from_not_demanded_loans!
    end

    context "EFG loans" do
      let!(:efg_loan1) { FactoryGirl.create(:loan, :lender_demand, borrower_demanded_on: 366.days.ago) }
      let!(:efg_loan2) { FactoryGirl.create(:loan, :lender_demand, borrower_demanded_on: 365.days.ago) }

      it "should not update loans as EFG loans have no time limit for demanding loans" do
        dispatch

        efg_loan1.reload.state.should == Loan::LenderDemand
        efg_loan2.reload.state.should == Loan::LenderDemand
      end
    end

    %w(sflg legacy_sflg).each do |scheme|
      context "#{scheme} loans" do
        let!(:expired_loan) { FactoryGirl.create(:loan, :lender_demand, scheme.to_sym, borrower_demanded_on: 366.days.ago) }
        let!(:unexpired_loan) { FactoryGirl.create(:loan, :lender_demand, scheme.to_sym, borrower_demanded_on: 365.days.ago) }

        it "should update state of loans with a borrower demanded date older than a year to auto-removed" do
          dispatch

          expired_loan.reload.state.should == Loan::AutoRemoved
          unexpired_loan.reload.state.should == Loan::LenderDemand
        end

        it_behaves_like "auto-updated loan"
      end
    end
  end

  describe ".remove_not_closed_loans!" do

    def dispatch
      LoanAutoUpdater.remove_not_closed_loans!
    end

    [
      Loan::Incomplete,
      Loan::Completed,
      Loan::Offered
    ].each do |state|
      context "#{state} EFG loans" do
        let!(:expired_loan) { FactoryGirl.create(:loan, state.to_sym, maturity_date: 6.months.ago.advance(days: -1)) }
        let!(:unexpired_loan) { FactoryGirl.create(:loan, state.to_sym, maturity_date: 6.months.ago) }

        it "should update state of loans with a maturity date older than 6 months to auto-removed" do
          dispatch

          expired_loan.reload.state.should == Loan::AutoRemoved
          unexpired_loan.reload.state.should == state
        end

        it_behaves_like "auto-updated loan"
      end
    end

    context 'guaranteed EFG loans' do
      let!(:expired_loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: 93.days.ago) }
      let!(:unexpired_loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: 92.days.ago) }

      it "should update state of loans with a maturity date older than 92 days to auto-removed" do
        dispatch

        expired_loan.reload.state.should == Loan::AutoRemoved
        unexpired_loan.reload.state.should == Loan::Guaranteed
      end

      it_behaves_like "auto-updated loan"
    end

    context 'lender_demand SFLG loans' do
      let!(:expired_loan) { FactoryGirl.create(:loan, :lender_demand, :sflg, maturity_date: 6.months.ago.advance(days: -1)) }
      let!(:unexpired_loan) { FactoryGirl.create(:loan, :lender_demand, :sflg, maturity_date: 6.months.ago) }

      it "should update state of loans with a maturity date older than 6 months to auto-removed" do
        dispatch

        expired_loan.reload.state.should == Loan::AutoRemoved
        unexpired_loan.reload.state.should == Loan::LenderDemand
      end

      it_behaves_like "auto-updated loan"
    end

    context 'demanded legacy SFLG loans' do
      let!(:expired_loan) { FactoryGirl.create(:loan, :demanded, :legacy_sflg, maturity_date: 6.months.ago.advance(days: -1)) }
      let!(:unexpired_loan) { FactoryGirl.create(:loan, :demanded, :legacy_sflg, maturity_date: 6.months.ago) }

      it "should update state of loans with a maturity date older than 6 months to auto-removed" do
        dispatch

        expired_loan.reload.state.should == Loan::AutoRemoved
        unexpired_loan.reload.state.should == Loan::Demanded
      end

      it_behaves_like "auto-updated loan"
    end
  end

end
