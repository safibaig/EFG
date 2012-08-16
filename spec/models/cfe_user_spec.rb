require 'spec_helper'

describe LenderUser do
  let(:user) { FactoryGirl.build(:cfe_user) }

  it_behaves_like 'User'

  describe '#lenders' do
    it "returns an array all all lenders" do
      user.lenders.should == Lender.all
    end
  end

end
