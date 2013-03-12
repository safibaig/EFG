require 'spec_helper'
require 'csv'

describe LoanReportCsvExport do
  describe "#generate" do
    let!(:lender) { FactoryGirl.create(:lender, organisation_reference_code: 'ABC123') }
    let!(:user) { FactoryGirl.create(:lender_user, lender: lender) }

    let(:loan_report_presenter) { LoanReportPresenter.new(user) }

    before do
      loan_report_presenter.lender_ids = [lender.id]
      loan_report_presenter.states = Loan::States
      loan_report_presenter.loan_sources = [Loan::SFLG_SOURCE]
      loan_report_presenter.loan_scheme = Loan::EFG_SCHEME
    end

    let(:loan_report_csv_export) { LoanReportCsvExport.new(loan_report_presenter.loans) }
    let(:csv) { CSV.new(loan_report_csv_export.generate, { headers: :first_row }) }

    let(:user1) { FactoryGirl.create(:user, username: 'bobby.t') }
    let(:user2) { FactoryGirl.create(:user, username: 'billy.bob') }
    let(:ded_code) {
      FactoryGirl.create(:ded_code,
        category_description: 'Loss of Market',
        code: 'A.10.1.1',
        code_description: 'Competition',
        group_description: 'Trading'
      )
    }
    let!(:initial_draw_change) {
      FactoryGirl.create(:initial_draw_change,
        amount_drawn: Money.new(10_000_00),
        date_of_change: Date.new(2012, 5, 17),
        loan: loan
      )
    }
    let(:invoice) { FactoryGirl.create(:invoice, reference: '123-INV') }
    let(:lending_limit) {
      FactoryGirl.create(:lending_limit,
        lender: lender,
        name: 'lending limit'
      )
    }
    let!(:loan_realisation) {
      FactoryGirl.create(:loan_realisation,
        created_at: Time.gm(2012, 8, 6),
        realised_amount: Money.new(3_000_00),
        realised_loan: loan
      )
    }
    let!(:loan_security_1) {
      FactoryGirl.create(:loan_security,
        loan: loan,
        loan_security_type_id: 1
      )
    }
    let!(:loan_security_2) {
      FactoryGirl.create(:loan_security,
        loan: loan,
        loan_security_type_id: 2
      )
    }
    let!(:lump_sum_repayment) {
      FactoryGirl.create(:loan_change,
        loan: loan,
        lump_sum_repayment: Money.new(5_000_00)
      )
    }
    let!(:recovery) {
      FactoryGirl.create(:recovery,
        loan: loan,
        amount_due_to_dti: Money.new(150_000_00),
        recovered_on: Date.new(2012, 7, 18)
      )
    }

    let!(:loan) {
      FactoryGirl.create(:loan,
        ded_code: ded_code,
        invoice: invoice,
        lender: lender,
        lending_limit: lending_limit,
        reference: 'ABC12345',
        legal_form_id: 1,
        postcode: 'EC1V 3WB',
        turnover: 5000000,
        trading_date: Date.new(2011, 5, 28),
        sic_code: 1,
        sic_desc: 'Sic description',
        sic_parent_desc: 'Sic parent description',
        reason_id: 1,
        amount: 250000,
        guarantee_rate: 75.0,
        premium_rate: 2.0,
        state: 'eligible',
        repayment_duration: { months: 24 },
        repayment_frequency_id: 1,
        maturity_date: Date.new(2025, 11, 5),
        generic1: 'generic1',
        generic2: 'generic2',
        generic3: 'generic3',
        generic4: 'generic4',
        generic5: 'generic5',
        cancelled_reason_id: 1,
        cancelled_comment: 'cancel comment',
        cancelled_on: Date.new(2012, 1, 22),
        facility_letter_date: Date.new(2012, 5, 16),
        borrower_demanded_on: Date.new(2012, 6, 18),
        amount_demanded: 10000,
        repaid_on: Date.new(2012, 9, 15),
        no_claim_on: Date.new(2012, 9, 16),
        dti_demanded_on: Date.new(2012, 9, 17),
        dti_demand_outstanding: 50000,
        dti_amount_claimed: 40000,
        dti_interest: 5000,
        dti_reason: 'failure!',
        dti_break_costs: 5000,
        created_by: user1,
        created_at: Time.zone.local(2012, 4, 12, 14, 34),
        modified_by: user2,
        updated_at: Time.zone.local(2012, 4, 13, 0, 34),
        remove_guarantee_on: Date.new(2012, 9, 16),
        remove_guarantee_outstanding_amount: 20000,
        remove_guarantee_reason: 'removal reason',
        state_aid: 5600,
        settled_on: Date.new(2012, 7, 17),
        loan_category_id: 1,
        interest_rate_type_id: 1,
        interest_rate: 2.0,
        fees: 5000,
        private_residence_charge_required: true,
        personal_guarantee_required: false,
        security_proportion: 70.0,
        current_refinanced_amount: 1000.00,
        final_refinanced_amount: 10000.00,
        original_overdraft_proportion: 60.0,
        refinance_security_proportion: 30.0,
        overdraft_limit: 5000,
        overdraft_maintained: true,
        invoice_discount_limit: 6000,
        debtor_book_coverage: 30,
        debtor_book_topup: 5,
        lender_reference: 'lenderref1',
      )
    }

    let(:row) { csv.shift }
    let(:header) { row.headers }

    it 'should return the correct headers' do
      header.should ==
        [
          :loan_reference,
          :legal_form,
          :post_code,
          :annual_turnover,
          :trading_date,
          :sic_code,
          :sic_code_description,
          :parent_sic_code_description,
          :purpose_of_loan,
          :facility_amount,
          :guarantee_rate,
          :premium_rate,
          :lending_limit,
          :lender_reference,
          :loan_state,
          :loan_term,
          :repayment_frequency,
          :maturity_date,
          :generic1,
          :generic2,
          :generic3,
          :generic4,
          :generic5,
          :cancellation_reason,
          :cancellation_comment,
          :cancellation_date,
          :scheme_facility_letter_date,
          :initial_draw_amount,
          :initial_draw_date,
          :lender_demand_date,
          :lender_demand_amount,
          :repaid_date,
          :no_claim_date,
          :demand_made_date,
          :outstanding_facility_principal,
          :total_claimed,
          :outstanding_facility_interest,
          :business_failure_group,
          :business_failure_category_description,
          :business_failure_description,
          :business_failure_code,
          :government_demand_reason,
          :break_cost,
          :latest_recovery_date,
          :total_recovered,
          :latest_realised_date,
          :total_realised,
          :cumulative_amount_drawn,
          :total_lump_sum_repayments,
          :created_by,
          :created_at,
          :modified_by,
          :modified_date,
          :guarantee_remove_date,
          :outstanding_balance,
          :guarantee_remove_reason,
          :state_aid_amount,
          :settled_date,
          :invoice_reference,
          :loan_category,
          :interest_type,
          :interest_rate,
          :fees,
          :type_a1,
          :type_a2,
          :type_b1,
          :type_d1,
          :type_d2,
          :type_c1,
          :security_type,
          :type_c_d1,
          :type_e1,
          :type_e2,
          :type_f1,
          :type_f2,
          :type_f3,
          :loan_lender_reference
        ].map {|h| t(h) }
    end

    it 'should return the correct data' do
      row[t(:loan_reference)].should == "ABC12345"
      row[t(:legal_form)].should == LegalForm.find(1).name
      row[t(:post_code)].should == 'EC1V 3WB'
      row[t(:annual_turnover)].should == '5000000.00'
      row[t(:trading_date)].should == '28-05-2011'
      row[t(:sic_code)].should == '1'
      row[t(:sic_code_description)].should == 'Sic description'
      row[t(:parent_sic_code_description)].should == 'Sic parent description'
      row[t(:purpose_of_loan)].should == LoanReason.find(1).name
      row[t(:facility_amount)].should == '250000.00'
      row[t(:guarantee_rate)].should == '75.0'
      row[t(:premium_rate)].should == '2.0'
      row[t(:lending_limit)].should == 'lending limit'
      row[t(:lender_reference)].should == 'ABC123'
      row[t(:loan_state)].should == 'Eligible'
      row[t(:loan_term)].should == '24'
      row[t(:repayment_frequency)].should == RepaymentFrequency.find(1).name
      row[t(:maturity_date)].should == '05-11-2025'
      row[t(:generic1)].should == 'generic1'
      row[t(:generic2)].should == 'generic2'
      row[t(:generic3)].should == 'generic3'
      row[t(:generic4)].should == 'generic4'
      row[t(:generic5)].should == 'generic5'
      row[t(:cancellation_reason)].should == CancelReason.find(1).name
      row[t(:cancellation_comment)].should == 'cancel comment'
      row[t(:cancellation_date)].should == '22-01-2012'
      row[t(:scheme_facility_letter_date)].should == '16-05-2012'
      row[t(:initial_draw_amount)].should == "10000.00"
      row[t(:initial_draw_date)].should == '17-05-2012'
      row[t(:lender_demand_date)].should == '18-06-2012'
      row[t(:lender_demand_amount)].should == "10000.00"
      row[t(:repaid_date)].should == '15-09-2012'
      row[t(:no_claim_date)].should == '16-09-2012'
      row[t(:demand_made_date)].should == '17-09-2012'
      row[t(:outstanding_facility_principal)].should == "50000.00"
      row[t(:total_claimed)].should == "40000.00"
      row[t(:outstanding_facility_interest)].should == "5000.00"
      row[t(:business_failure_group)].should == 'Trading'
      row[t(:business_failure_category_description)].should == 'Loss of Market'
      row[t(:business_failure_description)].should == 'Competition'
      row[t(:business_failure_code)].should == 'A.10.1.1'
      row[t(:government_demand_reason)].should == 'failure!'
      row[t(:break_cost)].should == "5000.00"
      row[t(:latest_recovery_date)].should == '18-07-2012'
      row[t(:total_recovered)].should == "150000.00"
      row[t(:latest_realised_date)].should == '06-08-2012'
      row[t(:total_realised)].should == "3000.00"
      row[t(:cumulative_amount_drawn)].should == "10000.00"
      row[t(:total_lump_sum_repayments)].should == "5000.00"
      row[t(:created_by)].should == 'bobby.t'
      row[t(:created_at)].should == '12-04-2012 02:34 PM'
      row[t(:modified_by)].should == 'billy.bob'
      row[t(:modified_date)].should == '13-04-2012'
      row[t(:guarantee_remove_date)].should == '16-09-2012'
      row[t(:outstanding_balance)].should == '20000.00'
      row[t(:guarantee_remove_reason)].should == 'removal reason'
      row[t(:state_aid_amount)].should == '5600.00'
      row[t(:settled_date)].should == '17-07-2012'
      row[t(:invoice_reference)].should == '123-INV'
      row[t(:loan_category)].should == LoanCategory.find(1).name
      row[t(:interest_type)].should == InterestRateType.find(1).name
      row[t(:interest_rate)].should == '2.0'
      row[t(:fees)].should == '5000.00'
      row[t(:type_a1)].should == 'Yes'
      row[t(:type_a2)].should == 'No'
      row[t(:type_b1)].should == '70.0'
      row[t(:type_d1)].should == '1000.00'
      row[t(:type_d2)].should == '10000.00'
      row[t(:type_c1)].should == '60.0'
      row[t(:security_type)].should == 'Residential property other than a principal private residence / Commercial property' # security_type
      row[t(:type_c_d1)].should == '30.0'
      row[t(:type_e1)].should == '5000.00'
      row[t(:type_e2)].should == 'Yes'
      row[t(:type_f1)].should == '6000.00'
      row[t(:type_f2)].should == '30.0'
      row[t(:type_f3)].should == '5.0'
      row[t(:loan_lender_reference)].should == 'lenderref1'
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_report')
  end

end
