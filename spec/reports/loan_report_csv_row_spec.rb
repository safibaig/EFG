require 'spec_helper'

describe LoanReportCsvRow do

  describe ".header" do
    let(:header) { LoanReportCsvRow.header }

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
    end
  end

  describe "#row" do
    let(:user) { FactoryGirl.create(:user) }

    let(:loan) {
      loan_allocation = FactoryGirl.create(:loan_allocation, description: 'allocation description')

      loan = FactoryGirl.create(
        :loan,
        reference: 'ABC12345',
        legal_form_id: 1,
        postcode: 'EC1V 3WB',
        non_validated_postcode: 'EC1',
        town: 'Camden',
        turnover: 5000000,
        trading_date: Date.parse('28/05/2011'),
        sic_code: 1,
        sic_desc: 'Sic description',
        sic_parent_desc: 'Sic parent description',
        reason_id: 1,
        amount: 250000,
        guarantee_rate: 75.0,
        premium_rate: 2.0,
        loan_allocation_id: loan_allocation.id,
        state: 'eligible',
        repayment_duration: { months: 24 },
        repayment_frequency_id: 1,
        maturity_date: '5/11/2025',
        generic1: 'generic1',
        generic2: 'generic2',
        generic3: 'generic3',
        generic4: 'generic4',
        generic5: 'generic5',
        cancelled_reason_id: 1,
        cancelled_comment: 'cancel comment',
        cancelled_on: Date.parse('22/01/2012'),
        facility_letter_date: Date.parse('16/05/2012'),
        initial_draw_value: 10000,
        initial_draw_date: Date.parse('17/05/2012'),
        borrower_demanded_on: Date.parse('18/06/2012'),
        amount_demanded: 10000,
        repaid_on: Date.parse('15/09/2012'),
        no_claim_on: Date.parse('16/09/2012'),
        dti_demanded_on: Date.parse('17/09/2012'),
        dti_demand_outstanding: 50000,
        dti_amount_claimed: 40000,
        dti_interest: 5000,
        dti_reason: 'failure!',
        dit_break_costs: 5000,
        created_by_id: user.id,
        created_at: Time.parse('12/04/2012 14:34'),
        # modified_by_id: user.id,
        updated_at: Time.parse('13/04/2012 14:34'),
        remove_guarantee_on: Date.parse('16/09/2012'),
        remove_guarantee_outstanding_amount: 20000,
        remove_guarantee_reason: 'removal reason',
        state_aid: 5600,
        settled_on: Date.parse('17/07/2012'),
        # @loan.invoice.try(:reference)
        loan_category_id: 1,
        interest_rate_type_id: 1,
        interest_rate: 2.0,
        fees: 5000,
        private_residence_charge_required: true,
        personal_guarantee_required: false,
        security_proportion: 70.0,
        current_refinanced_value: 1000.00,
        final_refinanced_value: 10000.00,
        original_overdraft_proportion: 60.0,
        refinance_security_proportion: 30.0,
        overdraft_limit: 5000,
        overdraft_maintained: true,
        invoice_discount_limit: 6000,
        debtor_book_coverage: 30,
        debtor_book_topup: 5
      )

      loan_realisation = FactoryGirl.create(
        :loan_realisation,
        realised_loan: loan,
        realised_amount: 3000,
        created_at: Date.parse('6/8/2012')
      )

      loan_recovery = FactoryGirl.create(
        :recovery,
        loan: loan,
        amount_due_to_dti: 150000,
        recovered_on: Date.parse('18/07/2012')
      )

      loan_change = FactoryGirl.create(
        :loan_change,
        loan: loan,
        amount_drawn: 10000,
        lump_sum_repayment: 5000
      )

      loan_security1 = FactoryGirl.create(:loan_security, loan: loan, loan_security_type_id: 1)
      loan_security2 = FactoryGirl.create(:loan_security, loan: loan, loan_security_type_id: 2)

      loan
    }

    let(:row) { LoanReportCsvRow.new(loan).row }

    it 'should return array of loan values' do
      row[0].should == "ABC12345"                                       # loan_reference
      row[1].should == LegalForm.find(1).name                           # legal_form
      row[2].should == 'EC1V 3WB'                                       # post_code
      row[3].should == 'EC1'                                            # non_validated_post_code
      row[4].should == 'Camden'                                         # town
      row[5].should == '5000000.00'                                     # annual_turnover
      row[6].should == '28-05-2011'                                     # trading_date
      row[7].should == 1                                                # sic_code
      row[8].should == 'Sic description'                                # sic_code_description
      row[9].should == 'Sic parent description'                         # parent_sic_code_description
      row[10].should == LoanReason.find(1).name                         # purpose_of_loan
      row[11].should == '250000.00'                                     # facility_amount
      row[12].should == 75.0                                            # guarantee_rate
      row[13].should == 2.0                                             # premium_rate
      row[14].should == 'allocation description'                        # lending_limit
      row[15].should == ''                                              # lender_reference
      row[16].should == 'eligible'                                      # loan_state
      row[17].should == 24                                              # loan_term
      row[18].should == RepaymentFrequency.find(1).name                 # repayment_frequency
      row[19].should == '05-11-2025'                                    # maturity_date
      row[20].should == 'generic1'                                      # generic1
      row[21].should == 'generic2'                                      # generic2
      row[22].should == 'generic3'                                      # generic3
      row[23].should == 'generic4'                                      # generic4
      row[24].should == 'generic5'                                      # generic5
      row[25].should == CancelReason.find(1).name                       # cancellation_reason
      row[26].should == 'cancel comment'                                # cancellation_comment
      row[27].should == '22-01-2012'                                    # cancellation_date
      row[28].should == '16-05-2012'                                    # scheme_facility_letter_date
      row[29].should == "10000.00"                                      # initial_draw_amount
      row[30].should == '17-05-2012'                                    # initial_draw_date
      row[31].should == '18-06-2012'                                    # lender_demand_date
      row[32].should == "10000.00"                                      # lender_demand_amount
      row[33].should == '15-09-2012'                                    # repaid_date
      row[34].should == '16-09-2012'                                    # no_claim_date
      row[35].should == '17-09-2012'                                    # demand_made_date
      row[36].should == "50000.00"                                      # outstanding_facility_principal
      row[37].should == "40000.00"                                      # total_claimed
      row[38].should == "5000.00"                                       # outstanding_facility_interest
      row[39].should == '' #loan.ded.group_description                  # business_failure_group
      row[40].should == '' #loan.ded.category_description               # business_failure_category_description
      row[41].should == '' # loan.ded.code_description                  # business_failure_description
      row[42].should == '' # loan.ded.code                              # business_failure_code
      row[43].should == 'failure!'                                      # government_demand_reason
      row[44].should == "5000.00"                                       # break_cost
      row[45].should == '18-07-2012'                                    # latest_recovery_date
      row[46].should == "150000.00"                                     # total_recovered
      row[47].should == '06-08-2012'                                    # latest_realised_date
      row[48].should == "3000.00"                                       # total_realised
      row[49].should == "10000.00"                                      # cumulative_amount_drawn
      row[50].should == "5000.00"                                       # total_lump_sum_repayments
      row[51].should == user.name                                       # created_by
      row[52].should == '12-04-2012 02:34 PM'                           # created_at
      row[53].should == user.name                                       # modified_by
      row[54].should == '13-04-2012'                                    # modified_date
      row[55].should == '16-09-2012'                                    # guarantee_remove_date
      row[56].should == '20000.00'                                      # outstanding_balance
      row[57].should == 'removal reason'                                # guarantee_remove_reason
      row[58].should == '5600.00'                                       # state_aid_amount
      row[59].should == '17-07-2012'                                    # settled_date
      row[60].should == '' # loan.invoice.try(:reference)               # invoice_reference
      row[61].should == LoanCategory.find(1).name                       # loan_category
      row[62].should == InterestRateType.find(1).name                   # interest_type
      row[63].should == 2.0                                             # interest_rate
      row[64].should == '5000.00'                                       # fees
      row[65].should == 'Yes'                                           # type_a1
      row[66].should == 'No'                                            # type_a2
      row[67].should == 70.0                                            # type_b1
      row[68].should == '1000.00'                                       # type_d1
      row[69].should == '10000.00'                                      # type_d2
      row[70].should == 60.0                                            # type_c1
      row[71].should == [                                               # security_type
        LoanSecurityType.find(1).name, LoanSecurityType.find(2).name
      ].join(' / ')
      row[72].should == 30.0                                            # type_c_d1
      row[73].should == '5000.00'                                       # type_e1
      row[74].should == 'Yes'                                           # type_e2
      row[75].should == '6000.00'                                       # type_f1
      row[76].should == 30                                              # type_f2
      row[77].should == 5                                               # type_f3
    end

    it 'should return array of same length as header array' do
      LoanReportCsvRow.header.size.should == row.size
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_report')
  end

end
