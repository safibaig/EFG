require 'spec_helper'
require 'csv'

describe LoanReportCsvExport do
  describe "#generate" do
    let!(:lender) { FactoryGirl.create(:lender, organisation_reference_code: 'ABC123') }
    let(:loan_report) { FactoryGirl.build(:loan_report, lender_ids: [lender.id]) }
    let(:loan_report_csv_export) { LoanReportCsvExport.new(loan_report.loans) }
    let(:parsed_csv) { CSV.parse(loan_report_csv_export.generate) }

    context 'header' do
      let(:header) { parsed_csv[0] }

      it "should return array of strings with correct text" do
        header[0].should == t(:loan_reference)
        header[1].should == t(:legal_form)
        header[2].should == t(:post_code)
        header[3].should == t(:non_validated_post_code)
        header[4].should == t(:town)
        header[5].should == t(:annual_turnover)
        header[6].should == t(:trading_date)
        header[7].should == t(:sic_code)
        header[8].should == t(:sic_code_description)
        header[9].should == t(:parent_sic_code_description)
        header[10].should == t(:purpose_of_loan)
        header[11].should == t(:facility_amount)
        header[12].should == t(:guarantee_rate)
        header[13].should == t(:premium_rate)
        header[14].should == t(:lending_limit)
        header[15].should == t(:lender_reference)
        header[16].should == t(:loan_state)
        header[17].should == t(:loan_term)
        header[18].should == t(:repayment_frequency)
        header[19].should == t(:maturity_date)
        header[20].should == t(:generic1)
        header[21].should == t(:generic2)
        header[22].should == t(:generic3)
        header[23].should == t(:generic4)
        header[24].should == t(:generic5)
        header[25].should == t(:cancellation_reason)
        header[26].should == t(:cancellation_comment)
        header[27].should == t(:cancellation_date)
        header[28].should == t(:scheme_facility_letter_date)
        header[29].should == t(:initial_draw_amount)
        header[30].should == t(:initial_draw_date)
        header[31].should == t(:lender_demand_date)
        header[32].should == t(:lender_demand_amount)
        header[33].should == t(:repaid_date)
        header[34].should == t(:no_claim_date)
        header[35].should == t(:demand_made_date)
        header[36].should == t(:outstanding_facility_principal)
        header[37].should == t(:total_claimed)
        header[38].should == t(:outstanding_facility_interest)
        header[39].should == t(:business_failure_group)
        header[40].should == t(:business_failure_category_description)
        header[41].should == t(:business_failure_description)
        header[42].should == t(:business_failure_code)
        header[43].should == t(:government_demand_reason)
        header[44].should == t(:break_cost)
        header[45].should == t(:latest_recovery_date)
        header[46].should == t(:total_recovered)
        header[47].should == t(:latest_realised_date)
        header[48].should == t(:total_realised)
        header[49].should == t(:cumulative_amount_drawn)
        header[50].should == t(:total_lump_sum_repayments)
        header[51].should == t(:created_by)
        header[52].should == t(:created_at)
        header[53].should == t(:modified_by)
        header[54].should == t(:modified_date)
        header[55].should == t(:guarantee_remove_date)
        header[56].should == t(:outstanding_balance)
        header[57].should == t(:guarantee_remove_reason)
        header[58].should == t(:state_aid_amount)
        header[59].should == t(:settled_date)
        header[60].should == t(:invoice_reference)
        header[61].should == t(:loan_category)
        header[62].should == t(:interest_type)
        header[63].should == t(:interest_rate)
        header[64].should == t(:fees)
        header[65].should == t(:type_a1)
        header[66].should == t(:type_a2)
        header[67].should == t(:type_b1)
        header[68].should == t(:type_d1)
        header[69].should == t(:type_d2)
        header[70].should == t(:type_c1)
        header[71].should == t(:security_type)
        header[72].should == t(:type_c_d1)
        header[73].should == t(:type_e1)
        header[74].should == t(:type_e2)
        header[75].should == t(:type_f1)
        header[76].should == t(:type_f2)
        header[77].should == t(:type_f3)
        header[78].should == t(:loan_lender_reference)
      end
    end

    context 'row' do
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
          non_validated_postcode: 'EC1',
          town: 'Camden',
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

      let(:row) { parsed_csv[1] }

      it 'should CSV data for loan' do
        row[0].should == "ABC12345"
        row[1].should == LegalForm.find(1).name
        row[2].should == 'EC1V 3WB'
        row[3].should == 'EC1'
        row[4].should == 'Camden'
        row[5].should == '5000000.00'
        row[6].should == '28-05-2011'
        row[7].should == '1'
        row[8].should == 'Sic description'
        row[9].should == 'Sic parent description'
        row[10].should == LoanReason.find(1).name
        row[11].should == '250000.00'
        row[12].should == '75.0'
        row[13].should == '2.0'
        row[14].should == 'lending limit'
        row[15].should == 'ABC123'
        row[16].should == 'Eligible'
        row[17].should == '24'
        row[18].should == RepaymentFrequency.find(1).name
        row[19].should == '05-11-2025'
        row[20].should == 'generic1'
        row[21].should == 'generic2'
        row[22].should == 'generic3'
        row[23].should == 'generic4'
        row[24].should == 'generic5'
        row[25].should == CancelReason.find(1).name
        row[26].should == 'cancel comment'
        row[27].should == '22-01-2012'
        row[28].should == '16-05-2012'
        row[29].should == "10000.00"
        row[30].should == '17-05-2012'
        row[31].should == '18-06-2012'
        row[32].should == "10000.00"
        row[33].should == '15-09-2012'
        row[34].should == '16-09-2012'
        row[35].should == '17-09-2012'
        row[36].should == "50000.00"
        row[37].should == "40000.00"
        row[38].should == "5000.00"
        row[39].should == 'Trading'
        row[40].should == 'Loss of Market'
        row[41].should == 'Competition'
        row[42].should == 'A.10.1.1'
        row[43].should == 'failure!'
        row[44].should == "5000.00"
        row[45].should == '18-07-2012'
        row[46].should == "150000.00"
        row[47].should == '06-08-2012'
        row[48].should == "3000.00"
        row[49].should == "10000.00"
        row[50].should == "5000.00"
        row[51].should == 'bobby.t'
        row[52].should == '12-04-2012 02:34 PM'
        row[53].should == 'billy.bob'
        row[54].should == '13-04-2012'
        row[55].should == '16-09-2012'
        row[56].should == '20000.00'
        row[57].should == 'removal reason'
        row[58].should == '5600.00'
        row[59].should == '17-07-2012'
        row[60].should == '123-INV'
        row[61].should == LoanCategory.find(1).name
        row[62].should == InterestRateType.find(1).name
        row[63].should == '2.0'
        row[64].should == '5000.00'
        row[65].should == 'Yes'
        row[66].should == 'No'
        row[67].should == '70.0'
        row[68].should == '1000.00'
        row[69].should == '10000.00'
        row[70].should == '60.0'
        row[71].should == 'Residential property other than a principal private residence / Commercial property' # security_type
        row[72].should == '30.0'
        row[73].should == '5000.00'
        row[74].should == 'Yes'
        row[75].should == '6000.00'
        row[76].should == '30.0'
        row[77].should == '5.0'
        row[78].should == 'lenderref1'
      end
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_report')
  end

end
