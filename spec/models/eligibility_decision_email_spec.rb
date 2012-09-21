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

    it "must have a loan" do
      eligibility_decision_email.loan = nil
      eligibility_decision_email.should_not be_valid
    end
  end

  describe "#deliver_email" do
    context 'with eligible loan' do
      let(:eligibility_decision_email) { FactoryGirl.build(:eligibility_decision_email) }

      it "should send email" do
        expect {
          eligibility_decision_email.deliver_email
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context 'with ineligible loan' do
      let(:eligibility_decision_email) { FactoryGirl.build(:ineligible_eligibility_decision_email) }

      it "should send email" do
        expect {
          eligibility_decision_email.deliver_email
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end

end
