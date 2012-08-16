require 'spec_helper'
require 'importers'

describe LenderUserAssociationImporter do
  describe '.import' do
    let!(:user1) { FactoryGirl.create(:cfe_admin, username: 'a') }
    let!(:user2) { FactoryGirl.create(:cfe_admin, username: 'b') }
    let!(:lender1) { FactoryGirl.create(:lender, created_by_legacy_id: 'a', modified_by_legacy_id: 'b') }
    let!(:lender2) { FactoryGirl.create(:lender, created_by_legacy_id: 'b', modified_by_legacy_id: 'a') }
    let!(:lender3) { FactoryGirl.create(:lender, created_by_legacy_id: '',  modified_by_legacy_id: 'a') }

    it do
      LenderUserAssociationImporter.import

      lender1.reload
      lender1.created_by.should == user1
      lender1.modified_by.should == user2

      lender2.reload
      lender2.created_by.should == user2
      lender2.modified_by.should == user1

      lender3.reload
      lender3.created_by.should be_nil
      lender3.modified_by.should == user1
    end
  end
end
