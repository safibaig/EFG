require 'spec_helper'

describe RealiseRecovery do
  describe "#realised?" do
    let(:recovery) { FactoryGirl.build(:recovery) }
    let(:realise_recovery) { RealiseRecovery.new(recovery) }

    it "is realised if set as post_claim_limit" do
      realise_recovery.realised = nil
      realise_recovery.post_claim_limit = true
      realise_recovery.should be_realised
    end

    it "is realised if realised, without post_claim_limit" do
      realise_recovery.realised = true
      realise_recovery.post_claim_limit = nil
      realise_recovery.should be_realised
    end

    it "isn't realised when not realised and not set as post_claim_limit" do
      realise_recovery.realised = nil
      realise_recovery.post_claim_limit = nil
      realise_recovery.should_not be_realised
    end
  end

  describe "#realise!" do
    let(:modifier) { FactoryGirl.create(:user) }
    let(:realisation_statement) { FactoryGirl.create(:realisation_statement) }
    let(:recovery) { FactoryGirl.create(:recovery) }
    let(:realise_recovery) { RealiseRecovery.new(recovery) }

    def run(realised = true)
      realise_recovery.realised = realised
      realise_recovery.realise!(realisation_statement, modifier)
    end

    context "with a realised recovery" do
      it "associates the realisation statement" do
        run
        recovery.reload

        recovery.realisation_statement.should == realisation_statement
      end

      it "marks the recovery as realised" do
        run
        recovery.reload

        recovery.realise_flag.should be_true
      end

      context "creating a loan realisation" do
        it "associates the recovery's loan " do
          run
          realisation = LoanRealisation.last

          realisation.realised_loan.should == recovery.loan
        end

        it "sets the creator to the modifier  " do
          run
          realisation = LoanRealisation.last

          realisation.created_by.should == modifier
        end

        it "sets the realised amount to the recovery's amount due" do
          run
          realisation = LoanRealisation.last

          realisation.realised_amount.should == recovery.amount_due_to_dti
        end

        it "sets the realised_on to today's date" do
          Timecop.freeze(2013, 4, 22, 17, 18, 0) { run }
          realisation = LoanRealisation.last

          realisation.realised_on.should == Date.new(2013, 4, 22)
        end

        it "sets the post claim limit to false if not selected" do
          run
          realisation = LoanRealisation.last

          realisation.post_claim_limit.should be_false
        end

        it "sets the post claim limit to true if selected" do
          realise_recovery.post_claim_limit = true
          run
          realisation = LoanRealisation.last

          realisation.post_claim_limit.should be_true
        end
      end
    end

    context "with a not realised recovery" do
      it "raises a NotMarkedAsRealised error" do
        expect {
          run(false)
        }.to raise_error(RealiseRecovery::NotMarkedAsRealised)
      end
    end
  end
end
