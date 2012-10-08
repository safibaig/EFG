require 'spec_helper'

describe LoanOffer do
  describe "validations" do
    let(:lending_limit) { FactoryGirl.build(:lending_limit) }

    let(:loan) { FactoryGirl.build(:loan, :completed, lending_limit: lending_limit) }

    let(:loan_offer) {
      loan_offer = LoanOffer.new(loan)
      loan_offer.facility_letter_date = lending_limit.starts_on
      loan_offer.facility_letter_sent = true
      loan_offer
    }

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

    it "should be invalid if loan's lending limit is inactive" do
      lending_limit.active = false
      loan_offer.should_not be_valid
    end

    it "should be invalid if loan's lending limit expired more than 6 months ago" do
      lending_limit.starts_on = 1.year.ago
      lending_limit.ends_on = 6.months.ago - 1.day
      loan_offer.should_not be_valid

      lending_limit.ends_on = 6.months.ago
      loan_offer.should be_valid
    end

    it "should be invalid if facility letter date is after loan's lending limit end dates" do
      loan_offer.facility_letter_date = lending_limit.ends_on + 1.day
      loan_offer.should_not be_valid
      loan_offer.facility_letter_date = lending_limit.ends_on
      loan_offer.should be_valid
    end

    it "should be invalid if facility letter date is before loan's lending limit start dates" do
      loan_offer.facility_letter_date = lending_limit.starts_on - 1.day
      loan_offer.should_not be_valid
      loan_offer.facility_letter_date = lending_limit.starts_on
      loan_offer.should be_valid
    end

    it "should be valid when a legacy SFLG loan without a lending limit" do
      loan.loan_source = Loan::LEGACY_SFLG_SOURCE
      loan.lending_limit = nil

      loan_offer.should be_valid
    end

    it "should be valid when a transferred loan without a lending limit" do
      loan.reference = 'ABCDEFG+02'
      loan.lending_limit = nil

      loan_offer.should be_valid
    end
  end
end
