require 'spec_helper'
require 'csv'

describe LoanCsvExport do

  let(:loan1) { FactoryGirl.build(:loan, :guaranteed, reference: "ABC2345-01") }

  let(:loan_csv_export) { LoanCsvExport.new([ loan1 ]) }

  describe '#generate' do
    let(:csv_data) { CSV.parse(loan_csv_export.generate) }

    it 'should return csv data with a header row and one row of data' do
      csv_data.size.should eq(2), "CSV should contain header and 1 row of data"
    end

    it 'should return csv data with correct header' do
      csv_data.first.should == loan_csv_export.send(:fields)
    end

    it 'should return correct csv data for loans' do
      loan_csv_export.send(:fields).each_with_index do |field, index|
        value = loan1.send(field)

        expected_value = case value.class.to_s
        when "Money"
          value.to_s
        when "CancelReason", "CfeUser", "InterestRateType", "LegalForm", "LegalForm",
             "LenderUser", "LoanCategory", "LoanReason", "Lender", "RepaymentFrequency"
          value.name
        when "LendingLimit"
          value.title
        when "MonthDuration"
          value.total_months.to_s
        when "NilClass"
          ""
        when "TrueClass"
          "Yes"
        when "FalseClass"
          "No"
        when "ActiveSupport::TimeWithZone"
          value.strftime('%d/%m/%Y %H:%M:%S')
        when "Date"
          value.strftime('%d/%m/%Y')
        when "BigDecimal"
          value.to_s
        else
          value
        end

        csv_data[1][index].should == expected_value
      end
    end
  end

end
