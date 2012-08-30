require 'spec_helper'

describe LoanReportCsvRow do

  describe "#row" do

    let(:user) { FactoryGirl.create(:user) }

    let!(:loan) {
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
        created_at: Time.zone.parse('12/04/2012 14:34'),
        modified_by_id: user.id,
        updated_at: Time.zone.parse('13/04/2012 14:34'),
        remove_guarantee_on: Date.parse('16/09/2012'),
        remove_guarantee_outstanding_amount: 20000,
        remove_guarantee_reason: 'removal reason',
        state_aid: 5600,
        settled_on: Date.parse('17/07/2012'),
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

      # stub custom fields that are created by LoanReport SQL query
      loan.stub(
        invoice: FactoryGirl.build(:invoice, reference: '123-INV'),
        _lending_limit_name: 'allocation description',
        _lender_organisation_reference_code: 'ABC123',
        _last_recovery_on: Date.parse('18-07-2012'),
        _total_recoveries: 15000000,
        _last_realisation_at: Date.parse('06-08-2012'),
        _total_loan_realisations: 300000,
        _total_amount_drawn: 1000000,
        _total_lump_sum_repayment: 500000,

      )

      loan_security1 = FactoryGirl.create(:loan_security, loan: loan, loan_security_type_id: 1)
      loan_security2 = FactoryGirl.create(:loan_security, loan: loan, loan_security_type_id: 2)

      loan
    }

    let(:row) { LoanReportCsvRow.new(loan).row }

    it 'should CSV data for loan' do
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
      row[12].should == '75.0'                                          # guarantee_rate
      row[13].should == '2.0'                                           # premium_rate
      row[14].should == 'allocation description'                        # lending_limit
      row[15].should == 'ABC123'                                        # lender_reference
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
      row[51].should == user.id                                         # created_by
      row[52].should == '12-04-2012 02:34 PM'                           # created_at
      row[53].should == user.id                                         # modified_by
      row[54].should == '13-04-2012'                                    # modified_date
      row[55].should == '16-09-2012'                                    # guarantee_remove_date
      row[56].should == '20000.00'                                      # outstanding_balance
      row[57].should == 'removal reason'                                # guarantee_remove_reason
      row[58].should == '5600.00'                                       # state_aid_amount
      row[59].should == '17-07-2012'                                    # settled_date
      row[60].should == '123-INV'                                       # invoice_reference
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
      row[76].should == 30.0                                            # type_f2
      row[77].should == 5.0                                             # type_f3
    end

  end

end
