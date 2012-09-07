require 'spec_helper'
require 'importers'

describe LoanSicCodeUpdateImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/loan_sic_code_mapping.csv') }

  describe ".import" do
    let!(:loan) {
      FactoryGirl.create(
        :loan,
        reference: 'GP9GR7V+01',
        sic_code: 'A01.11.001',
        legacy_sic_code: 'A01.11.001',
        legacy_sic_desc: 'Legacy description',
        legacy_sic_eligible: false,
        legacy_sic_parent_desc: 'Legacy parent description',
        legacy_sic_notified_aid: true,
      )
    }

    let!(:sic_code) {
      FactoryGirl.create(
        :sic_code,
        code: '01110',
        description: 'Growing of cereals (except rice)',
        eligible: true
      )
    }

    before do
      LoanSicCodeUpdateImporter.csv_path = csv_fixture_path
      LoanSicCodeUpdateImporter.instance_variable_set(:@sic_codes, nil)
    end

    def dispatch
      LoanSicCodeUpdateImporter.import
    end

    it "should update existing SIC code and related fields to 2007 standard" do
      dispatch

      loan.reload
      loan.sic_code.should == "01110"
      loan.sic_desc.should == "Growing of cereals (except rice)"
      loan.sic_eligible.should == true
      loan.sic_parent_desc.should be_nil
      loan.sic_notified_aid.should be_nil
    end

    it "should not change legacy SIC data" do
      dispatch

      loan.reload
      loan.legacy_sic_code.should == 'A01.11.001'
      loan.legacy_sic_desc.should == 'Legacy description'
      loan.legacy_sic_eligible.should == false
      loan.legacy_sic_parent_desc.should == 'Legacy parent description'
      loan.legacy_sic_notified_aid.should == true
    end

    it "should not change created_at and updated_at timestamps" do
      original_created_at = loan.created_at
      original_updated_at = loan.updated_at

      Timecop.freeze(1.minute.from_now) do
        dispatch

        loan.reload
        loan.updated_at.to_i.should == original_updated_at.to_i
        loan.created_at.to_i.should == original_created_at.to_i
      end
    end
  end

end
