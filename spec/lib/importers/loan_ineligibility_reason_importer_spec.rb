require 'spec_helper'
require 'importers'

describe LoanIneligibilityReasonImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_LOAN_RR_DATA_TABLE.csv') }

  let!(:loan1) { FactoryGirl.create(:loan, legacy_id: '123') }

  let!(:loan2) { FactoryGirl.create(:loan, legacy_id: '124') }

  describe ".import" do
    before do
      LoanIneligibilityReasonImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
    end

    def dispatch
      LoanIneligibilityReasonImporter.csv_path = csv_fixture_path
      LoanIneligibilityReasonImporter.import
    end

    it "should create new records" do
      expect {
        dispatch
      }.to change(LoanIneligibilityReason, :count).by(2)
    end

    it "should import data correctly" do
      dispatch

      loan_ineligibility_reason1 = LoanIneligibilityReason.first
      loan_ineligibility_reason1.loan.should == loan1
      loan_ineligibility_reason1.sequence.should == 0
      loan_ineligibility_reason1.reason.should == "Reason1\nReason2"
      loan_ineligibility_reason1.ar_timestamp.should == Time.gm(2006, 9, 29)
      loan_ineligibility_reason1.ar_insert_timestamp.should == Time.gm(2006, 9, 28)

      loan_ineligibility_reason2 = LoanIneligibilityReason.last
      loan_ineligibility_reason2.loan.should == loan2
      loan_ineligibility_reason2.sequence.should == 1
      loan_ineligibility_reason2.reason.should == "Reason3\nReason4"
      loan_ineligibility_reason2.ar_timestamp.should == Time.gm(2006, 11, 01)
      loan_ineligibility_reason2.ar_insert_timestamp.should == Time.gm(2006, 10, 28)
    end
  end

end
