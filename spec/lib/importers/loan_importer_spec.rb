require 'spec_helper'
require 'importers'

describe LoanImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loans.csv') }

  describe ".import" do
    let!(:lender) { FactoryGirl.create(:lender, legacy_id: 9) }
    let!(:loan_allocation) { FactoryGirl.create(:loan_allocation, lender: lender, legacy_id: 47) }
    let!(:creator_user) { FactoryGirl.create(:lender_user, legacy_id: '8008769F7E055AEBA0033AD3880965BB0E99142A') }
    let!(:modifier_user) { FactoryGirl.create(:lender_user, legacy_id: '8467CE2D5BE4B96EC60E11BD466B61514D1A33D5') }

    before do
      LoanImporter.csv_path = csv_fixture_path
      LoanImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      LoanImporter.instance_variable_set(:@user_id_from_legacy_id, nil)
    end

    def dispatch
      LoanImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(Loan, :count).by(1)
    end

    it "should import data correctly" do
      dispatch

      loan = Loan.last
      loan.lender.should == lender
      loan.loan_allocation.should == loan_allocation
      loan.legacy_id.should == 685
      loan.reference.should == "BCHNIQ5-01"
      loan.amount.should == Money.new(10000000)
      loan.trading_date.should == Date.new(2006, 1, 10)
      loan.turnover.should == Money.new(136500000)
      loan.state.should == Loan::Guaranteed
      loan.created_by_legacy_id.should == "8008769F7E055AEBA0033AD3880965BB0E99142A"
      loan.created_by.should == creator_user
      loan.created_at.should == Time.gm(2005, 12, 19)
      loan.updated_at.should_not be_blank # after_import hook will update this to current time
      loan.version.should == 11
      loan.guaranteed_on.should == Date.new(2005, 12, 20)
      loan.modified_by_legacy_id.should == "8467CE2D5BE4B96EC60E11BD466B61514D1A33D5"
      loan.modified_by.should == modifier_user
      loan.lender_legacy_id.should == 9
      loan.outstanding_amount.should == Money.new(500000)
      loan.standard_cap.should == false
      loan.business_name.should == "BUSINESS NAME"
      loan.trading_name.should == "ACME"
      loan.company_registration.should == "COMPANYREG"
      loan.postcode.should == "AA11 2BB"
      loan.branch_sortcode.should == "990099"
      loan.repayment_duration.should == MonthDuration.new(60)
      loan.cancelled_comment.should == "n/a"
      loan.next_change_history_seq.should == 3
      loan.declaration_signed.should == true
      loan.borrower_demanded_on.should == Date.new(2007, 7, 20)
      loan.cancelled_on.should == Date.new(2007, 7, 30)
      loan.repaid_on.should == Date.new(2010, 10, 5)
      loan.viable_proposition.should == true
      loan.collateral_exhausted.should == true
      loan.generic1.should == "n/a1"
      loan.generic2.should == "n/a2"
      loan.generic3.should == "n/a3"
      loan.generic4.should == "n/a4"
      loan.generic5.should == "n/a5"
      loan.facility_letter_date.should == Date.new(2006, 1, 12)
      loan.facility_letter_sent.should == true
      loan.dti_demanded_on.should == Date.new(2007, 9, 11)
      loan.dti_demand_outstanding.should == Money.new(7999996)
      loan.borrower_demand_outstanding.should == Money.new(30000)
      loan.realised_money_date.should == Date.new(2007, 6, 30)
      loan.no_claim_on.should == Date.new(2010, 6, 30)
      loan.event_legacy_id.should == 18
      loan.state_aid.should == Money.new(1471100, 'EUR')
      loan.previous_borrowing.should == true
      loan.would_you_lend.should == true
      loan.ar_timestamp.should == Time.gm(2006, 12, 11)
      loan.ar_insert_timestamp.should == Time.gm(2005, 12, 19)
      loan.maturity_date.should == Date.new(2011, 6, 6)
      loan.first_pp_received.should == true
      loan.signed_direct_debit_received.should == true
      loan.received_declaration.should == true
      loan.state_aid_is_valid.should == true
      loan.notified_aid.should == false
      loan.sic_code.should == "K74.87/9.013"
      loan.remove_guarantee_outstanding_amount.should == Money.new(40000)
      loan.remove_guarantee_on.should == Date.new(2009, 5, 8)
      loan.remove_guarantee_reason.should == "n/a"
      loan.dti_amount_claimed.should == Money.new(6077668)
      loan.invoice_legacy_id.should == 44
      loan.settled_on.should == Date.new(2007, 10, 22)
      loan.amount_demanded.should == Money.new(7999996)
      loan.next_borrower_demand_seq.should == 1
      loan.sic_desc.should == "Franchisers"
      loan.sic_parent_desc.should == "Other business activities not elsewhere classified"
      loan.sic_notified_aid.should == false
      loan.sic_eligible.should == true
      loan.lender_cap_id.should == 47
      loan.town.should == "London"
      loan.non_val_postcode.should == "ec1123"
      loan.transferred_from_legacy_id.should == 12345
      loan.next_in_calc_seq.should == 2
      loan.dti_reason.should == "n/a"
      loan.loan_source.should == "S"
      loan.dit_break_costs.should == Money.new(0)
      loan.guarantee_rate.should == 70
      loan.premium_rate.should == 0
      loan.legacy_small_loan.should == false
      loan.next_in_realise_seq.should == 0
      loan.next_in_recover_seq.should == 0
      loan.recovery_on.should == Date.new(2010, 8, 20)
      loan.recovery_statement_legacy_id.should == 123456
      loan.dti_ded_code.should == "A.10.56"
      loan.dti_interest.should == Money.new(103561)
      loan.loan_scheme.should == "S"
      loan.interest_rate_type_id.should == 1
      loan.interest_rate.should == 5.4
      loan.fees.should == Money.new(50000)
      loan.reason_id.should == 26
      loan.business_type.should == 4
      loan.payment_period.should == 4
      loan.cancelled_reason_id.should == 1
      loan.loan_category_id.should == 20
      loan.private_residence_charge_required.should == false
      loan.personal_guarantee_required.should == false
      loan.security_proportion.should == 50
      loan.current_refinanced_value.should == Money.new(480000)
      loan.final_refinanced_value.should == Money.new(550000)
      loan.original_overdraft_proportion.should == 30
      loan.refinance_security_proportion.should == 50
      loan.overdraft_limit.should == Money.new(40000)
      loan.overdraft_maintained.should == false
      loan.invoice_discount_limit.should == Money.new(50000)
      loan.debtor_book_coverage.should == 300
      loan.debtor_book_topup.should == 300
    end
  end
end
