require 'spec_helper'
require 'importers'

describe AdminAuditImporter do
  describe '.import' do
    let!(:lender1) { FactoryGirl.create(:lender, legacy_id: 441) }
    let!(:lender2) { FactoryGirl.create(:lender, legacy_id: 81) }
    let!(:lender3) { FactoryGirl.create(:lender, legacy_id: 123) }
    let!(:lending_limit1) { FactoryGirl.create(:lending_limit, legacy_id: 324) }
    let!(:lending_limit2) { FactoryGirl.create(:lending_limit, legacy_id: 164) }
    let!(:lending_limit3) { FactoryGirl.create(:lending_limit, legacy_id: 205) }
    let!(:user1) { FactoryGirl.create(:cfe_user, username: 'a') }
    let!(:user2) { FactoryGirl.create(:lender_user, username: 'b') }
    let!(:user3) { FactoryGirl.create(:cfe_admin, username: 'c') }
    let!(:user4) { FactoryGirl.create(:user, username: 'd') }

    before do
      AdminAuditImporter.csv_path = Rails.root.join('spec/fixtures/import_data/admin_audits.csv')
      AdminAuditImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
      AdminAuditImporter.instance_variable_set(:@lending_limit_id_from_legacy_id, nil)
      AdminAuditImporter.instance_variable_set(:@user_id_from_username, nil)
      AdminAuditImporter.import
    end

    it do
      admin_audits = AdminAudit.all
      admin_audits.length.should == 17

      admin_audits[0].action.should == AdminAudit::LendingLimitCreated
      admin_audits[0].auditable.should == lending_limit1
      admin_audits[0].legacy_id.should == 805
      admin_audits[0].legacy_object_id.should == '324'
      admin_audits[0].legacy_object_type.should == 'lender_cap_alloc'
      admin_audits[0].legacy_object_version.should == 0
      admin_audits[0].modified_by.should == user1
      admin_audits[0].modified_on.should == Date.new(2007, 4, 24)

      admin_audits[1].action.should == AdminAudit::LendingLimitEdited
      admin_audits[1].auditable.should == lending_limit2
      admin_audits[1].legacy_id.should == 963
      admin_audits[1].legacy_object_id.should == '164'
      admin_audits[1].legacy_object_type.should == 'lender_cap_alloc'
      admin_audits[1].legacy_object_version.should == 1
      admin_audits[1].modified_by.should == user1
      admin_audits[1].modified_on.should == Date.new(2007, 5, 16)

      admin_audits[2].action.should == AdminAudit::UserInitialLogin
      admin_audits[2].auditable.should == user2
      admin_audits[2].auditable_type.should == 'User'
      admin_audits[2].legacy_id.should == 828
      admin_audits[2].legacy_object_id.should == 'b'
      admin_audits[2].legacy_object_type.should == 'user'
      admin_audits[2].legacy_object_version.should == 2
      admin_audits[2].modified_by.should == user2
      admin_audits[2].modified_on.should == Date.new(2007, 4, 30)

      admin_audits[3].action.should == 'Knowledge resource flag changed'
      admin_audits[3].auditable.should == user3
      admin_audits[3].auditable_type.should == 'User'
      admin_audits[3].legacy_id.should == 846
      admin_audits[3].legacy_object_id.should == 'c'
      admin_audits[3].legacy_object_type.should == 'user'
      admin_audits[3].legacy_object_version.should == 1
      admin_audits[3].modified_by.should == user3
      admin_audits[3].modified_on.should == Date.new(2007, 4, 30)

      admin_audits[4].action.should == AdminAudit::LenderCreated
      admin_audits[4].auditable.should == lender1
      admin_audits[4].legacy_id.should == 818
      admin_audits[4].legacy_object_id.should == '441'
      admin_audits[4].legacy_object_type.should == 'lender'
      admin_audits[4].legacy_object_version.should == 0
      admin_audits[4].modified_by.should == user1
      admin_audits[4].modified_on.should == Date.new(2007, 4, 24)

      admin_audits[5].action.should == AdminAudit::LenderDisabled
      admin_audits[5].auditable.should == lender2
      admin_audits[5].legacy_id.should == 666
      admin_audits[5].legacy_object_id.should == '81'
      admin_audits[5].legacy_object_type.should == 'lender'
      admin_audits[5].legacy_object_version.should == 3
      admin_audits[5].modified_by.should == user1
      admin_audits[5].modified_on.should == Date.new(2007, 4, 10)

      admin_audits[6].action.should == AdminAudit::LenderEdited
      admin_audits[6].auditable.should == lender1
      admin_audits[6].legacy_id.should == 638
      admin_audits[6].legacy_object_id.should == '441'
      admin_audits[6].legacy_object_type.should == 'lender'
      admin_audits[6].legacy_object_version.should == 1
      admin_audits[6].modified_by.should == user1
      admin_audits[6].modified_on.should == Date.new(2007, 2, 9)

      admin_audits[7].action.should == AdminAudit::LenderEnabled
      admin_audits[7].auditable.should == lender3
      admin_audits[7].legacy_id.should == 776
      admin_audits[7].legacy_object_id.should == '123'
      admin_audits[7].legacy_object_type.should == 'lender'
      admin_audits[7].legacy_object_version.should == 7
      admin_audits[7].modified_by.should == user1
      admin_audits[7].modified_on.should == Date.new(2007, 4, 24)

      admin_audits[8].action.should == 'Main point of contact set'
      admin_audits[8].auditable.should == lender3
      admin_audits[8].legacy_id.should == 821
      admin_audits[8].legacy_object_id.should == '123'
      admin_audits[8].legacy_object_type.should == 'lender'
      admin_audits[8].legacy_object_version.should == 8
      admin_audits[8].modified_by.should == user3
      admin_audits[8].modified_on.should == Date.new(2007, 4, 27)

      admin_audits[9].action.should == AdminAudit::LendingLimitRemoved
      admin_audits[9].auditable.should == lending_limit3
      admin_audits[9].legacy_id.should == 665
      admin_audits[9].legacy_object_id.should == '205'
      admin_audits[9].legacy_object_type.should == 'lender_cap_alloc'
      admin_audits[9].legacy_object_version.should == 1
      admin_audits[9].modified_by.should == user2
      admin_audits[9].modified_on.should == Date.new(2007, 4, 2)

      admin_audits[10].action.should == AdminAudit::UserCreated
      admin_audits[10].auditable.should == user4
      admin_audits[10].auditable_type.should == 'User'
      admin_audits[10].legacy_id.should == 851
      admin_audits[10].legacy_object_id.should == 'd'
      admin_audits[10].legacy_object_type.should == 'user'
      admin_audits[10].legacy_object_version.should == 0
      admin_audits[10].modified_by.should == user4
      admin_audits[10].modified_on.should == Date.new(2007, 4, 30)

      admin_audits[11].action.should == AdminAudit::UserDisabled
      admin_audits[11].auditable.should == user4
      admin_audits[11].auditable_type.should == 'User'
      admin_audits[11].legacy_id.should == 876
      admin_audits[11].legacy_object_id.should == 'd'
      admin_audits[11].legacy_object_type.should == 'user'
      admin_audits[11].legacy_object_version.should == 3
      admin_audits[11].modified_by.should == user4
      admin_audits[11].modified_on.should == Date.new(2007, 5, 8)

      admin_audits[12].action.should == AdminAudit::UserEdited
      admin_audits[12].auditable.should == user1
      admin_audits[12].auditable_type.should == 'User'
      admin_audits[12].legacy_id.should == 820
      admin_audits[12].legacy_object_id.should == 'a'
      admin_audits[12].legacy_object_type.should == 'user'
      admin_audits[12].legacy_object_version.should == 2
      admin_audits[12].modified_by.should == user1
      admin_audits[12].modified_on.should == Date.new(2007, 4, 24)

      admin_audits[13].action.should == AdminAudit::UserEnabled
      admin_audits[13].auditable.should == user2
      admin_audits[13].auditable_type.should == 'User'
      admin_audits[13].legacy_id.should == 776
      admin_audits[13].legacy_object_id.should == 'b'
      admin_audits[13].legacy_object_type.should == 'user'
      admin_audits[13].legacy_object_version.should == 37
      admin_audits[13].modified_by.should == user4
      admin_audits[13].modified_on.should == Date.new(2007, 4, 24)

      admin_audits[14].action.should == AdminAudit::UserPasswordChanged
      admin_audits[14].auditable.should == user3
      admin_audits[14].auditable_type.should == 'User'
      admin_audits[14].legacy_id.should == 840
      admin_audits[14].legacy_object_id.should == 'c'
      admin_audits[14].legacy_object_type.should == 'user'
      admin_audits[14].legacy_object_version.should == 14
      admin_audits[14].modified_by.should == user3
      admin_audits[14].modified_on.should == Date.new(2007, 4, 27)

      admin_audits[15].action.should == 'User reset'
      admin_audits[15].auditable.should == user3
      admin_audits[15].auditable_type.should == 'User'
      admin_audits[15].legacy_id.should == 844
      admin_audits[15].legacy_object_id.should == 'c'
      admin_audits[15].legacy_object_type.should == 'user'
      admin_audits[15].legacy_object_version.should == 1
      admin_audits[15].modified_by.should == user4
      admin_audits[15].modified_on.should == Date.new(2007, 4, 30)

      admin_audits[16].action.should == AdminAudit::UserUnlocked
      admin_audits[16].auditable.should == user4
      admin_audits[16].auditable_type.should == 'User'
      admin_audits[16].legacy_id.should == 854
      admin_audits[16].legacy_object_id.should == 'd'
      admin_audits[16].legacy_object_type.should == 'user'
      admin_audits[16].legacy_object_version.should == 10
      admin_audits[16].modified_by.should == user3
      admin_audits[16].modified_on.should == Date.new(2007, 5, 1)
    end
  end
end
