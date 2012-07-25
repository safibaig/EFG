require 'spec_helper'
require 'importers'

describe LoanSecurityImporter do

  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, :eligible, legacy_id: 244955) }
    let!(:loan2) { FactoryGirl.create(:loan, :eligible, legacy_id: 244959) }

    let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_LOAN_SECURITY_DATA_TABLE.csv') }

    before(:each) do
      LoanSecurityImporter.instance_variable_set('@loan_id_from_legacy_id', nil)
      LoanSecurityImporter.csv_path = csv_fixture_path
    end

    def dispatch
      LoanSecurityImporter.import
    end

    it 'creates new loan security records' do
      expect {
        dispatch
      }.to change(LoanSecurity, :count).by(2)
    end

    it 'imports row 1' do
      dispatch

      loan_security = LoanSecurity.first
      loan_security.loan.should == loan1
      loan_security.loan_security_type.should == LoanSecurityType.find(7)
    end

    it 'imports row 2' do
      dispatch

      loan_security = LoanSecurity.last
      loan_security.loan.should == loan2
      loan_security.loan_security_type.should == LoanSecurityType.find(2)
    end

  end
end
