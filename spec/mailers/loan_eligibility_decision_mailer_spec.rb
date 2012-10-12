require 'spec_helper'

describe LoanEligibilityDecisionMailer do

  shared_examples_for "loan eligibility decision email" do
    it "should be sent to correct recipients" do
      email.to.should == [ "joe@example.com" ]
    end

    it "should have a from header" do
      Devise.mailer_sender.should match email.from[0]
    end

    it "should contain the loan reference" do
      email.body.should include(loan.reference)
    end
  end

  describe "#loan_eligible_email" do
    let(:loan) { FactoryGirl.build(:loan, :eligible) }

    let(:email) { LoanEligibilityDecisionMailer.loan_eligible_email("joe@example.com", loan) }

    it_behaves_like "loan eligibility decision email"
  end

  describe "#loan_ineligible_email" do
    let(:loan) { FactoryGirl.build(:loan, :rejected) }

    let(:email) { LoanEligibilityDecisionMailer.loan_ineligible_email("joe@example.com", loan) }

    it_behaves_like "loan eligibility decision email"

    it "should contain the loan rejection reasons" do
      loan.ineligibility_reasons.each do |ineligibility_reason|
        email.body.should include(ineligibility_reason.reason)
      end
    end
  end

end
