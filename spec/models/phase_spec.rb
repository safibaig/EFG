require 'spec_helper'

describe Phase do
  describe "validations" do
    let(:phase) { FactoryGirl.build(:phase) }

    it "has a valid factory" do
      phase.should be_valid
    end

    it "must have a name" do
      phase.name = ''
      phase.should_not be_valid
    end
  end
end
