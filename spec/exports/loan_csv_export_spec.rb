require 'spec_helper'
require 'csv'

describe LoanCsvExport do
  describe '#generate' do
    let(:user) { FactoryGirl.build(:cfe_user, first_name: 'Joe', last_name: 'Bloggs') }
    let(:lender) { FactoryGirl.build(:lender, name: 'Little Tinkers') }
    let(:lending_limit) { FactoryGirl.build(:lending_limit, name: 'Lending Limit') }
    let(:loan) {
      FactoryGirl.build(:loan, :guaranteed,
        created_by: user,
        lender: lender,
        lending_limit: lending_limit,
        maturity_date: Date.new(2022, 2, 22),
        reference: 'ABC2345-01',
        trading_date: Date.new(1999, 9, 9)
      )
    }
    let(:csv_data) {
      Timecop.freeze(Time.local(2012, 10, 1, 16, 23, 45))
      csv = LoanCsvExport.new([loan]).generate
      Timecop.return
      CSV.parse(csv)
    }

    it 'should return csv data with a header row and one row of data' do
      csv_data.size.should eq(2), "CSV should contain header and 1 row of data"
    end

    it 'should return csv data with correct header' do
      csv_data.first.should == %w(reference amount amount_demanded
        borrower_demanded_on sortcode business_name cancelled_comment
        cancelled_on cancelled_reason collateral_exhausted
        company_registration created_at created_by current_refinanced_amount
        debtor_book_coverage debtor_book_topup declaration_signed
        dti_break_costs dti_amount_claimed dti_ded_code
        dti_demand_outstanding dti_demanded_on dti_interest dti_reason
        facility_letter_date facility_letter_sent fees final_refinanced_amount
        first_pp_received generic1 generic2 generic3 generic4 generic5
        guarantee_rate guaranteed_on initial_draw_date initial_draw_amount
        interest_rate interest_rate_type invoice_discount_limit
        legacy_small_loan legal_form lender lending_limit loan_category
        loan_scheme loan_source maturity_date next_borrower_demand_seq
        next_change_history_seq next_in_calc_seq next_in_realise_seq
        next_in_recover_seq no_claim_on non_val_postcode
        non_validated_postcode notified_aid original_overdraft_proportion
        outstanding_amount overdraft_limit overdraft_maintained
        personal_guarantee_required postcode premium_rate previous_borrowing
        private_residence_charge_required realised_money_date reason
        received_declaration recovery_on refinance_security_proportion
        remove_guarantee_on remove_guarantee_outstanding_amount
        remove_guarantee_reason repaid_on repayment_duration
        repayment_frequency security_proportion settled_on sic_code sic_desc
        sic_eligible sic_notified_aid sic_parent_desc
        signed_direct_debit_received standard_cap state state_aid
        state_aid_is_valid town trading_date trading_name transferred_from
        turnover updated_at viable_proposition would_you_lend)
    end

    it 'should return correct csv data for loans' do
      row = csv_data[1]
      row[ 0].should == 'ABC2345-01'
      row[ 1].should == '12345.00'
      row[ 2].should == ''
      row[ 3].should == ''
      row[ 4].should == ''
      row[ 5].should == 'Acme'
      row[ 6].should == ''
      row[ 7].should == ''
      row[ 8].should == ''
      row[ 9].should == 'Yes'
      row[10].should == 'B1234567890'
      row[11].should == '01/10/2012 16:23:45'
      row[12].should == 'Joe Bloggs'
      row[13].should == ''
      row[14].should == ''
      row[15].should == ''
      row[16].should == ''
      row[17].should == ''
      row[18].should == ''
      row[19].should == ''
      row[20].should == ''
      row[21].should == ''
      row[22].should == ''
      row[23].should == ''
      row[24].should == ''
      row[25].should == ''
      row[26].should == '50000.00'
      row[27].should == ''
      row[28].should == 'Yes'
      row[29].should == ''
      row[30].should == ''
      row[31].should == ''
      row[32].should == ''
      row[33].should == ''
      row[34].should == '75.0'
      row[35].should == ''
      row[36].should == ''
      row[37].should == ''
      row[38].should == ''
      row[39].should == ''
      row[40].should == ''
      row[41].should == 'No'
      row[42].should == 'Sole Trader'
      row[43].should == 'Little Tinkers'
      row[44].should == 'Lending Limit'
      row[45].should == 'Type A - New Term Loan with No Security'
      row[46].should == 'E'
      row[47].should == 'S'
      row[48].should == '22/02/2022'
      row[49].should == ''
      row[50].should == ''
      row[51].should == ''
      row[52].should == ''
      row[53].should == ''
      row[54].should == ''
      row[55].should == ''
      row[56].should == 'AB1 2CD'
      row[57].should == ''
      row[58].should == ''
      row[59].should == ''
      row[60].should == ''
      row[61].should == ''
      row[62].should == 'No'
      row[63].should == 'EC1R 4RP'
      row[64].should == '2.0'
      row[65].should == 'Yes'
      row[66].should == 'No'
      row[67].should == ''
      row[68].should == 'Start-up costs'
      row[69].should == 'Yes'
      row[70].should == ''
      row[71].should == ''
      row[72].should == ''
      row[73].should == ''
      row[74].should == ''
      row[75].should == ''
      row[76].should == '24'
      row[77].should == 'Monthly'
      row[78].should == ''
      row[79].should == ''
      row[80].should == '12345'
      row[81].should == 'Growing of rice'
      row[82].should == 'Yes'
      row[83].should == ''
      row[84].should == ''
      row[85].should == 'Yes'
      row[86].should == ''
      row[87].should == 'guaranteed'
      row[88].should == '10000.00'
      row[89].should == 'Yes'
      row[90].should == 'London'
      row[91].should == '09/09/1999'
      row[92].should == 'Emca'
      row[93].should == ''
      row[94].should == '12345.00'
      row[95].should == '01/10/2012 16:23:45'
      row[96].should == 'Yes'
      row[97].should == 'Yes'
    end
  end
end
