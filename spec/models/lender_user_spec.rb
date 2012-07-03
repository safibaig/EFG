require 'spec_helper'

describe LenderUser do
  let(:user) { FactoryGirl.build(:lender_user) }

  it_behaves_like 'User'
end
