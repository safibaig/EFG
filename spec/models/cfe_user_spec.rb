require 'spec_helper'

describe LenderUser do
  let(:user) { FactoryGirl.build(:cfe_user) }

  it_behaves_like 'User'
end
