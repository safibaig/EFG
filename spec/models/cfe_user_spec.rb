require 'spec_helper'

describe CfeUser do
  let(:user) { FactoryGirl.build(:cfe_user) }

  it_behaves_like 'User'

  describe '#lenders' do
    before do
      FactoryGirl.create(:lender)
      FactoryGirl.create(:lender)
    end

    it "returns all lenders" do
      user.lenders.should == Lender.all
    end
  end
end
