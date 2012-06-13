require 'spec_helper'

describe User do

  describe "validations" do
    let(:user) { FactoryGirl.build(:user) }

    it "should have a valid factory" do
      user.should be_valid
    end

    it "should require a first_name" do
      user.first_name = ''
      user.should_not be_valid
    end

    it "should require a last_name" do
      user.last_name = ''
      user.should_not be_valid
    end

    it 'requires a lender' do
      pending "Remove rails 3.2 feature"
      # expect {
      #   user.lender = nil
      #   user.valid?
      # }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end

end
