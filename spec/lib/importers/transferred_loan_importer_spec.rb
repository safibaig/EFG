require 'spec_helper'
require 'importers'

describe TransferredLoanImporter do

  let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/transferred_loans.csv') }

  let!(:loan1) { FactoryGirl.create(:loan, reference: 'JSBZNIJ-01', legacy_id: 123) }

  let!(:loan2) { FactoryGirl.create(:loan, reference: 'RWONPRT-01', legacy_id: 456) }

  let!(:loan3) { FactoryGirl.create(:loan, reference: 'XWV3RWU-01', legacy_id: 789) }

  describe ".import" do
    before do
      TransferredLoanImporter.instance_variable_set(:@loan_id_from_legacy_id, nil)
      TransferredLoanImporter.csv_path = csv_fixture_path
    end

    def dispatch
      TransferredLoanImporter.import
    end

    it "should associate transferred loans with the correct original loan" do
      dispatch

      loan1.reload.transferred_from.should == loan2
      loan2.reload.transferred_from.should == loan3
      loan3.reload.transferred_from.should be_nil
    end
  end

end
