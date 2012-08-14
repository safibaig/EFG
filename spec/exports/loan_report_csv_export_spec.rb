require 'spec_helper'
require 'csv'

describe LoanReportCsvExport do

  describe "#initialize" do
    it "should raise exception when argument is not ActiveRecord::Relation object" do
      expect {
        LoanReportCsvExport.new("123")
      }.to raise_error(ArgumentError)
    end

    it "should not raise error when argument is ActiveRecord::Relation object" do
      expect {
        LoanReportCsvExport.new(Loan.scoped)
      }.to_not raise_error
    end
  end

  describe ".header" do
    let(:loan_report_csv_export) { LoanReportCsvExport.new(Loan.scoped) }

    let(:header) { loan_report_csv_export.header }

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

  describe "#generate" do

    let!(:loan) { FactoryGirl.create(:loan) }

    let(:loan_report_mock) { double(LoanReportCsvRow) }

    let(:row_mock) { Array.new(loan_report_csv_export.header.size) }

    let(:loan_report_csv_export) { LoanReportCsvExport.new(Loan.scoped) }

    let(:parsed_csv) { CSV.parse(loan_report_csv_export.generate) }

    before(:each) do
      LoanReportCsvRow.should_receive(:new).once.and_return(loan_report_mock)
      loan_report_mock.should_receive(:row).once.and_return(row_mock)
    end

    it "should return a row for the header and each loan" do
      parsed_csv.size.should == 2
    end

    it "should return the header in the first row" do
      parsed_csv[0].should == loan_report_csv_export.header
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_report')
  end

end
