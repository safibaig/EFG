require 'spec_helper'

describe 'Managing CfeAdmins as CfeAdmin' do

  let(:current_user) { FactoryGirl.create(:cfe_admin) }

  it_should_behave_like 'CfeAdmin user management'

end
