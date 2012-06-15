require 'spec_helper'
require 'importers'

describe LoanImporter do

  let!(:lender) { FactoryGirl.create(:lender, legacy_id: 9) }

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loans.csv') }

  describe "#values" do
    let(:row) { CSV.read(csv_fixture_path, headers: true).first }
    let(:importer) { LoanImporter.new(row) }

    it "should return an array of attributes" do
      importer.attributes.should == {
        :legacy_id                           => "685",
        :reference                           => "BCHNIQ5-01",
        :amount                              => 10000000,
        :trading_date                        => Date.parse("10-JAN-06"),
        :turnover                            => 136500000,
        :state                               => Loan::Guaranteed,
        :created_by_legacy_id                => "8008769F7E055AEBA0033AD3880965BB0E99142A",
        :created_at                          => Date.parse("19-DEC-05"),
        :updated_at                          => Date.parse("22-OCT-07"),
        :version                             => "11",
        :guaranteed_on                       => Date.parse("20-DEC-05"),
        :modified_by_legacy_id               => "8467CE2D5BE4B96EC60E11BD466B61514D1A33D5",
        :lender_legacy_id                    => "9",
        :lender_id                           => lender.id,
        :outstanding_amount                  => 500000,
        :standard_cap                        => "0",
        :business_name                       => "BUSINESS NAME",
        :trading_name                        => "ACME",
        :company_registration                => "COMPANYREG",
        :postcode                            => "AA11 2BB",
        :branch_sortcode                     => "990099",
        :repayment_duration                  => 60,
        :cancelled_comment                   => "n/a",
        :next_change_history_seq             => "3",
        :declaration_signed                  => "1",
        :borrower_demanded_on                => Date.parse("20-JUL-07"),
        :cancelled_on                        => Date.parse("30-JUL-07"),
        :repaid_on                           => Date.parse("05-OCT-10"),
        :viable_proposition                  => "1",
        :collateral_exhausted                => "1",
        :generic1                            => "n/a1",
        :generic2                            => "n/a2",
        :generic3                            => "n/a3",
        :generic4                            => "n/a4",
        :generic5                            => "n/a5",
        :facility_letter_date                => Date.parse("12-JAN-06"),
        :facility_letter_sent                => "1",
        :dti_demanded_on                     => Date.parse("11-SEP-07"),
        :dti_demand_outstanding              => 7999996,
        :borrower_demand_outstanding         => 30000,
        :realised_money_date                 => Date.parse("30-JUN-07"),
        :no_claim_on                         => Date.parse("30-JUN-10"),
        :event_legacy_id                     => "18",
        :state_aid                           => 1471100,
        :previous_borrowing                  => "1",
        :would_you_lend                      => "1",
        :ar_timestamp                        => Date.parse("11-DEC-06"),
        :ar_insert_timestamp                 => Date.parse("19-DEC-05"),
        :maturity_date                       => Date.parse("06-JUN-11"),
        :first_pp_received                   => "1",
        :signed_direct_debit_received        => "1",
        :received_declaration                => "1",
        :state_aid_is_valid                  => "1",
        :notified_aid                        => "0",
        :sic_code                            => "K74.87/9.013",
        :remove_guarantee_outstanding_amount => 40000,
        :remove_guarantee_on                 => Date.parse("08-MAY-09"),
        :remove_guarantee_reason             => "n/a",
        :dti_amount_claimed                  => 6077668,
        :invoice_legacy_id                   => "44",
        :settled_on                          => Date.parse("22-OCT-07"),
        :borrower_demanded_amount            => 7999996,
        :next_borrower_demand_seq            => "1",
        :sic_desc                            => "Franchisers",
        :sic_parent_desc                     => "Other business activities not elsewhere classified",
        :sic_notified_aid                    => "0",
        :sic_eligible                        => "1",
        :lender_cap_id                       => "47",
        :town                                => "London",
        :non_val_postcode                    => "ec1123",
        :transferred_from                    => "12345",
        :next_in_calc_seq                    => "2",
        :dti_reason                          => "n/a",
        :loan_source                         => "S",
        :dit_break_costs                     => 0,
        :guarantee_rate                      => "70",
        :premium_rate                        => "0",
        :legacy_small_loan                   => "0",
        :next_in_realise_seq                 => "0",
        :next_in_recover_seq                 => "0",
        :recovery_on                         => Date.parse("20-AUG-10"),
        :recovery_statement_legacy_id        => "123456",
        :dti_ded_code                        => "A.10.56",
        :dti_interest                        => 103561,
        :loan_scheme                         => "S",
        :interest_rate_type_id               => 1,
        :interest_rate                       => "5.4",
        :fees                                => 50000,
        :reason_id                           => "26",
        :business_type                       => "4",
        :payment_period                      => "4",
        :cancelled_reason                    => "1",
        :loan_category_id                    => "20",
        :private_residence_charge_required   => "0",
        :personal_guarantee_required         => "0",
        :security_proportion                 => "50",
        :current_refinanced_value            => 480000,
        :final_refinanced_value              => 550000,
        :original_overdraft_proportion       => "30",
        :refinance_security_proportion       => "50",
        :overdraft_limit                     => 40000,
        :overdraft_maintained                => "0",
        :invoice_discount_limit              => 50000,
        :debtor_book_coverage                => "300",
        :debtor_book_topup                   => "300"
      }
    end
  end

  describe ".import" do
    def dispatch
      LoanImporter.csv_path = csv_fixture_path
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
      loan.legacy_id.should == 685
      loan.reference.should == "BCHNIQ5-01"
      loan.amount.should == Money.new(10000000)
      loan.trading_date.should == Date.parse("10-JAN-06")
      loan.turnover.should == Money.new(136500000)
      loan.state.should == Loan::Guaranteed
      loan.created_by_legacy_id.should == "8008769F7E055AEBA0033AD3880965BB0E99142A"
      loan.created_at.should == Time.parse("19-DEC-05")
      loan.updated_at.should_not be_blank # after_import hook will update this to current time
      loan.version.should == 11
      loan.guaranteed_on.should == Date.parse("20-DEC-05")
      loan.modified_by_legacy_id.should == "8467CE2D5BE4B96EC60E11BD466B61514D1A33D5"
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
      loan.borrower_demanded_on.should == Date.parse("20-JUL-07")
      loan.cancelled_on.should == Date.parse("30-JUL-07")
      loan.repaid_on.should == Date.parse("05-OCT-10")
      loan.viable_proposition.should == true
      loan.collateral_exhausted.should == true
      loan.generic1.should == "n/a1"
      loan.generic2.should == "n/a2"
      loan.generic3.should == "n/a3"
      loan.generic4.should == "n/a4"
      loan.generic5.should == "n/a5"
      loan.facility_letter_date.should == Date.parse("12-JAN-06")
      loan.facility_letter_sent.should == true
      loan.dti_demanded_on.should == Date.parse("11-SEP-07")
      loan.dti_demand_outstanding.should == Money.new(7999996)
      loan.borrower_demand_outstanding.should == Money.new(30000)
      loan.realised_money_date.should == Date.parse("30-JUN-07")
      loan.no_claim_on.should == Date.parse("30-JUN-10")
      loan.event_legacy_id.should == 18
      loan.state_aid.should == Money.new(1471100)
      loan.previous_borrowing.should == true
      loan.would_you_lend.should == true
      loan.ar_timestamp.should == Time.parse("11-DEC-06")
      loan.ar_insert_timestamp.should == Time.parse("19-DEC-05")
      loan.maturity_date.should == Date.parse("06-JUN-11")
      loan.first_pp_received.should == true
      loan.signed_direct_debit_received.should == true
      loan.received_declaration.should == true
      loan.state_aid_is_valid.should == true
      loan.notified_aid.should == false
      loan.sic_code.should == "K74.87/9.013"
      loan.remove_guarantee_outstanding_amount.should == Money.new(40000)
      loan.remove_guarantee_on.should == Date.parse("08-MAY-09")
      loan.remove_guarantee_reason.should == "n/a"
      loan.dti_amount_claimed.should == Money.new(6077668)
      loan.invoice_legacy_id.should == 44
      loan.settled_on.should == Date.parse("22-OCT-07")
      loan.borrower_demanded_amount.should == Money.new(7999996)
      loan.next_borrower_demand_seq.should == 1
      loan.sic_desc.should == "Franchisers"
      loan.sic_parent_desc.should == "Other business activities not elsewhere classified"
      loan.sic_notified_aid.should == false
      loan.sic_eligible.should == true
      loan.lender_cap_id.should == 47
      loan.town.should == "London"
      loan.non_val_postcode.should == "ec1123"
      loan.transferred_from.should == 12345
      loan.next_in_calc_seq.should == 2
      loan.dti_reason.should == "n/a"
      loan.loan_source.should == "S"
      loan.dit_break_costs.should == Money.new(0)
      loan.guarantee_rate.should == 70
      loan.premium_rate.should == 0
      loan.legacy_small_loan.should == false
      loan.next_in_realise_seq.should == 0
      loan.next_in_recover_seq.should == 0
      loan.recovery_on.should == Date.parse("20-AUG-10")
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
      loan.cancelled_reason.should == 1
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

    it "should associate loan with lender" do
      dispatch

      Loan.last.lender.should == lender
    end
  end

end
