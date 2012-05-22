require 'spec_helper'

describe User do

  describe "validations" do
    let(:user) { FactoryGirl.build(:user) }

    it "should have a valid factory" do
      user.should be_valid
    end

    it "should require a name" do
      user.name = ''
      user.should_not be_valid
    end

    it 'requires a lender' do
      expect {
        user.lender = nil
        user.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end

end
