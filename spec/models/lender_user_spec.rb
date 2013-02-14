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
    before do
      FactoryGirl.create(:lender)
    end

    it "only contains this user's lender" do
      user.lenders.count.should == 1
      user.lenders.should include(user.lender)
    end
  end
end
