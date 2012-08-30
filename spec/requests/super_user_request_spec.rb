require 'spec_helper'

describe 'Managing CfeAdmins as SuperUser' do

  let(:current_user) { FactoryGirl.create(:super_user) }

  it_should_behave_like 'CfeAdmin user management'

end
