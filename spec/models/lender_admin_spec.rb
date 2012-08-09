require 'spec_helper'

describe LenderAdmin do
  let(:user) { FactoryGirl.build(:lender_admin) }

  it_behaves_like 'User'

  describe 'validations' do
    it 'requires a lender' do
      user.lender = nil
      user.should_not be_valid
    end
  end
end
