require 'spec_helper'
require 'csv'

describe LoanCsvExport do
  describe '#generate' do
    let(:user) { FactoryGirl.create(:cfe_user, first_name: 'Joe', last_name: 'Bloggs') }
    let(:lender) { FactoryGirl.create(:lender, name: 'Little Tinkers') }
    let(:lending_limit) { FactoryGirl.create(:lending_limit, name: 'Lending Limit') }
    let(:loan) {
      FactoryGirl.create(:loan, :guaranteed,
        created_by: user,
        lender: lender,
        lending_limit: lending_limit,
        maturity_date: Date.new(2022, 2, 22),
        reference: 'ABC2345-01',
        trading_date: Date.new(1999, 9, 9),
        lender_reference: 'lenderref1'
      )
    }
    let(:csv) {
      Timecop.freeze(2012, 10, 1, 16, 23, 45) do
        loan
      end

      csv = LoanCsvExport.new(Loan.scoped).generate
      CSV.new(csv, { headers: :first_row })
    }

    let(:row) { csv.shift }
    let(:header) { row.headers }

    it 'should return csv data with one row of data' do
      csv.to_a.size.should eq(1)
    end

    it 'should return csv data with correct header' do
      header.should == %w(reference amount amount_demanded
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
        notified_aid original_overdraft_proportion
        outstanding_amount overdraft_limit overdraft_maintained
        personal_guarantee_required postcode premium_rate previous_borrowing
        private_residence_charge_required realised_money_date reason
        received_declaration recovery_on refinance_security_proportion
        remove_guarantee_on remove_guarantee_outstanding_amount
        remove_guarantee_reason repaid_on repayment_duration
        repayment_frequency security_proportion settled_on sic_code sic_desc
        sic_eligible sic_notified_aid sic_parent_desc
        signed_direct_debit_received standard_cap state state_aid
        state_aid_is_valid trading_date trading_name transferred_from
        turnover updated_at viable_proposition would_you_lend lender_reference)
    end

    it 'should return correct csv data for loans' do
      row['reference'].should == 'ABC2345-01'
      row['amount'].should == '12345.00'
      row['amount_demanded'].should == ''
      row['borrower_demanded_on'].should == ''
      row['sortcode'].should == ''
      row['business_name'].should == 'Acme'
      row['cancelled_comment'].should == ''
      row['cancelled_on'].should == ''
      row['cancelled_reason'].should == ''
      row['collateral_exhausted'].should == 'Yes'
      row['company_registration'].should == ''
      row['created_at'].should == '01/10/2012 16:23:45'
      row['created_by'].should == 'Joe Bloggs'
      row['current_refinanced_amount'].should == ''
      row['debtor_book_coverage'].should == ''
      row['debtor_book_topup'].should == ''
      row['declaration_signed'].should == ''
      row['dti_break_costs'].should == ''
      row['dti_amount_claimed'].should == ''
      row['dti_ded_code'].should == ''
      row['dti_demand_outstanding'].should == ''
      row['dti_demanded_on'].should == ''
      row['dti_interest'].should == ''
      row['dti_reason'].should == ''
      row['facility_letter_date'].should == ''
      row['facility_letter_sent'].should == ''
      row['fees'].should == '50000.00'
      row['final_refinanced_amount'].should == ''
      row['first_pp_received'].should == 'Yes'
      row['generic1'].should == ''
      row['generic2'].should == ''
      row['generic3'].should == ''
      row['generic4'].should == ''
      row['generic5'].should == ''
      row['guarantee_rate'].should == '75.0'
      row['guaranteed_on'].should == ''
      row['initial_draw_date'].should == '01/10/2012'
      row['initial_draw_amount'].should == '10000.00'
      row['interest_rate'].should == ''
      row['interest_rate_type'].should == ''
      row['invoice_discount_limit'].should == ''
      row['legacy_small_loan'].should == 'No'
      row['legal_form'].should == 'Sole Trader'
      row['lender'].should == 'Little Tinkers'
      row['lending_limit'].should == 'Lending Limit'
      row['loan_category'].should == 'Type A - New Term Loan with No Security'
      row['loan_scheme'].should == 'E'
      row['loan_source'].should == 'S'
      row['maturity_date'].should == '22/02/2022'
      row['next_borrower_demand_seq'].should == ''
      row['next_change_history_seq'].should == ''
      row['next_in_calc_seq'].should == ''
      row['next_in_realise_seq'].should == ''
      row['next_in_recover_seq'].should == ''
      row['no_claim_on'].should == ''
      row['non_val_postcode'].should == ''
      row['notified_aid'].should == '0'
      row['original_overdraft_proportion'].should == ''
      row['outstanding_amount'].should == ''
      row['overdraft_limit'].should == ''
      row['overdraft_maintained'].should == ''
      row['personal_guarantee_required'].should == 'No'
      row['postcode'].should == 'EC1R 4RP'
      row['premium_rate'].should == '2.0'
      row['previous_borrowing'].should == 'Yes'
      row['private_residence_charge_required'].should == 'No'
      row['realised_money_date'].should == ''
      row['reason'].should == 'Start-up costs'
      row['received_declaration'].should == 'Yes'
      row['recovery_on'].should == ''
      row['refinance_security_proportion'].should == ''
      row['remove_guarantee_on'].should == ''
      row['remove_guarantee_outstanding_amount'].should == ''
      row['remove_guarantee_reason'].should == ''
      row['repaid_on'].should == ''
      row['repayment_duration'].should == '24'
      row['repayment_frequency'].should == 'Monthly'
      row['security_proportion'].should == ''
      row['settled_on'].should == ''
      row['sic_code'].should == '12345'
      row['sic_desc'].should == 'Growing of rice'
      row['sic_eligible'].should == 'Yes'
      row['sic_notified_aid'].should == ''
      row['sic_parent_desc'].should == ''
      row['signed_direct_debit_received'].should == 'Yes'
      row['standard_cap'].should == ''
      row['state'].should == 'guaranteed'
      row['state_aid'].should == '10000.00'
      row['state_aid_is_valid'].should == 'Yes'
      row['trading_date'].should == '09/09/1999'
      row['trading_name'].should == 'Emca'
      row['transferred_from'].should == ''
      row['turnover'].should == '12345.00'
      row['updated_at'].should == '01/10/2012 16:23:45'
      row['viable_proposition'].should == 'Yes'
      row['would_you_lend'].should == 'Yes'
      row['lender_reference'].should == 'lenderref1'
    end
  end
end
