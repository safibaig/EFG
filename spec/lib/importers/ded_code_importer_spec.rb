require 'spec_helper'
require 'importers'

describe DedCodeImporter do
  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_DED_DATA_TABLE.csv') }

  describe '.import' do
    before do
      DedCodeImporter.csv_path = csv_fixture_path
    end

    def dispatch
      DedCodeImporter.import
    end

    it 'should create new user records' do
      expect {
        dispatch
      }.to change(DedCode, :count).by(2)
    end

    it 'should import data correctly' do
      dispatch

      ded_code1 = DedCode.first
      ded_code1.legacy_id.should == "1"
      ded_code1.group_description.should == "Trading"
      ded_code1.category_description.should == "Loss of Market"
      ded_code1.code.should == "A.10.10"
      ded_code1.code_description.should == "Competition"
      ded_code1.ar_timestamp.should == Time.gm(2006, 10, 28)
      ded_code1.ar_insert_timestamp.should == Time.gm(2006, 10, 27)

      ded_code2 = DedCode.last
      ded_code2.legacy_id.should == "2"
      ded_code2.group_description.should == "Non-trading"
      ded_code2.category_description.should == "Loss on the sale of a property"
      ded_code2.code.should == "B.55.99"
      ded_code2.code_description.should == "Not classified"
      ded_code2.ar_timestamp.should == Time.gm(2006, 11, 29)
      ded_code2.ar_insert_timestamp.should == Time.gm(2006, 11, 28)
    end
  end
end
