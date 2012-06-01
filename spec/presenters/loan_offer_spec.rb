require 'spec_helper'

describe LoanOffer do
  describe "validations" do
    let(:loan_offer) { FactoryGirl.build(:loan_offer) }

    it "should have a valid factory" do
      loan_offer.should be_valid
    end

    it "should be invalid without the facility letter sent" do
      loan_offer.facility_letter_sent = false
      loan_offer.should_not be_valid
    end

    it "should be invalid without the facility letter date" do
      loan_offer.facility_letter_date = ''
      loan_offer.should_not be_valid
    end
  end
end
