require 'spec_helper'

describe EligibilityDecisionEmail do

  describe "validations" do
    let(:eligibility_decision_email) { FactoryGirl.build(:eligibility_decision_email) }

    it "should have a valid factory" do
      eligibility_decision_email.should be_valid
    end

    it "must have an email" do
      eligibility_decision_email.email = nil
      eligibility_decision_email.should_not be_valid
    end
  end

end
