require 'spec_helper'

describe Phase do
  describe "validations" do
    let(:phase) { FactoryGirl.build(:phase) }

    it "has a valid factory" do
      phase.should be_valid
    end

    it "must have a name" do
      expect {
        phase.name = ''
        phase.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
