require 'spec_helper'
require 'importers'

describe UserRoleMapper do

  let(:user_roles_csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/user_roles.csv') }

  describe ".user_type" do
    before do
      UserRoleMapper.user_roles_csv_path = user_roles_csv_fixture_path
    end

    {
      'ahan8063s' => 'LenderUser',
      'will8561s' => 'LenderAdmin',
      'thom5918r' => 'CfeAdmin',
      'jaya6359d' => 'PremiumCollectorUser',
      'jack1234e' => 'AuditorUser',
      'mull5432n' => 'CfeUser'
    }.each do |username, expected_user_type|
      it "should return correct user type for user #{username}" do
        user = FactoryGirl.build(:user, legacy_id: username)
        UserRoleMapper.new(user).user_type.should == expected_user_type
      end
    end
  end

end
