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

    it "must have a creator" do
      expect {
        phase.created_by = nil
        phase.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it "must have a modifier" do
      expect {
        phase.modified_by = nil
        phase.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
