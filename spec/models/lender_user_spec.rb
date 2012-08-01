require 'spec_helper'

describe LenderUser do
  let(:user) { FactoryGirl.build(:lender_user) }

  it_behaves_like 'User'

  describe 'validations' do
    it 'requires a lender' do
      user.lender = nil
      user.should_not be_valid
    end
  end

  describe '#lenders' do
    it "returns an array containing only this user's lender record" do
      user.lenders.should == [ user.lender ]
    end
  end
end
