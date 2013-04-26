require 'spec_helper'

describe RealisationStatementReceived do
  describe "validations" do
    let(:realisation_statement_received) { FactoryGirl.build(:realisation_statement_received) }

    context "details" do
      it "must have a valid factory" do
        realisation_statement_received.should be_valid
      end

      it "must have a lender" do
        realisation_statement_received.lender = nil
        realisation_statement_received.should_not be_valid
      end

      it "must have a reference" do
        realisation_statement_received.reference = ''
        realisation_statement_received.should_not be_valid
      end

      it "must have a period_covered_quarter" do
        realisation_statement_received.period_covered_quarter = ''
        realisation_statement_received.should_not be_valid
      end

      it "must have a valid period_covered_quarter" do
        realisation_statement_received.period_covered_quarter = 'February'
        realisation_statement_received.should_not be_valid
      end

      it "must have a period_covered_year" do
        realisation_statement_received.period_covered_year = ''
        realisation_statement_received.should_not be_valid
      end

      it "must have a valid period_covered_year" do
        realisation_statement_received.period_covered_year = 'junk'
        realisation_statement_received.should_not be_valid
      end

      it "must have a valid received_on" do
        realisation_statement_received.received_on = ''
        realisation_statement_received.should_not be_valid
      end
    end

    context "save" do
      it "must have recoveries to be realised" do
        realisation_statement_received.recoveries.each do |recovery|
          recovery.realised = false
        end

        realisation_statement_received.should_not be_valid(:save)
      end

      it "must have a creator" do
        expect {
          realisation_statement_received.creator = nil
          realisation_statement_received.valid?(:save)
        }.to raise_error(ActiveModel::StrictValidationFailed)
      end
    end
  end

  describe "#recoveries" do
    let(:realisation_statement_received) { FactoryGirl.build(:realisation_statement_received, period_covered_quarter: 'March', period_covered_year: '2012') }
    let(:loan) { FactoryGirl.create(:loan, lender: realisation_statement_received.lender, settled_on: Date.new(2010)) }

    let!(:specified_quarter_recovery) { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2012, 3, 31)) }
    let!(:previous_quarter_recovery)  { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2011, 12, 31)) }
    let!(:next_quarter_recovery)      { FactoryGirl.create(:recovery, loan: loan, recovered_on: Date.new(2012, 6, 30)) }

    it "should return recoveries within or prior to the specified quarter" do
      recoveries = realisation_statement_received.recoveries.map(&:recovery)

      recoveries.size.should == 2
      recoveries.should =~ [previous_quarter_recovery, specified_quarter_recovery]
    end

    it 'does not include recoveries from other lenders' do
      other_lender_recovery = FactoryGirl.create(:recovery, recovered_on: Date.new(2012))

      realisation_statement_received.recoveries.should_not include(other_lender_recovery)
    end

    it 'does not include already realised recoveries' do
      already_recovered_recovery = FactoryGirl.create(:recovery, loan: loan, realise_flag: true)

      realisation_statement_received.recoveries.should_not include(already_recovered_recovery)
    end
  end

  describe "#save" do
    let(:realisation_statement_received) { FactoryGirl.build(:realisation_statement_received, lender: lender) }
    let(:lender) { FactoryGirl.create(:lender) }

    context 'with valid loans to be realised' do
      let(:loan1) { FactoryGirl.create(:loan, :recovered, lender: lender, settled_on: Date.new(2000)) }
      let(:loan2) { FactoryGirl.create(:loan, :recovered, lender: lender, settled_on: Date.new(2000)) }
      let(:recovery1) { FactoryGirl.create(:recovery, loan: loan1, amount_due_to_dti: Money.new(123_00), recovered_on: Date.new(2006, 6)) }
      let(:recovery2) { FactoryGirl.create(:recovery, loan: loan2, amount_due_to_dti: Money.new(456_00), recovered_on: Date.new(2006, 6)) }
      let(:recovery3) { FactoryGirl.create(:recovery, loan: loan2, amount_due_to_dti: Money.new(789_00), recovered_on: Date.new(2006, 6)) }

      before do
        recoveries_to_realise_ids = [recovery1.id, recovery2.id, recovery3.id]
        realisation_statement_received.recoveries.select {|recovery| recoveries_to_realise_ids.include?(recovery.id)}.each do |recovery|
          recovery.realised = true
        end

        realisation_statement_received.save
      end

      it 'updates all loans to be realised to Realised state' do
        loan1.reload.state.should == Loan::Realised
        loan2.reload.state.should == Loan::Realised
      end

      it 'updates recoveries to be realised' do
        recovery1.reload.realise_flag.should be_true
        recovery2.reload.realise_flag.should be_true
        recovery3.reload.realise_flag.should be_true
      end

      it 'updates realised_money_date on all loans' do
        loan1.reload.realised_money_date.should == Date.today
        loan2.reload.realised_money_date.should == Date.today
      end

      it 'creates loan realisation for each recovery' do
        LoanRealisation.count.should == 3
      end

      it 'creates loan realisations with the same created by user as the realisation statement' do
        realisation_statement = realisation_statement_received.realisation_statement
        realisation_statement_received.realisation_statement.loan_realisations.each do |loan_realisation|
          loan_realisation.created_by.should == realisation_statement.created_by
        end
      end

      it 'stores the realised amount on each new loan realisation' do
        realisation_statement = realisation_statement_received.realisation_statement
        realised_amounts = realisation_statement.loan_realisations.map(&:realised_amount)
        realised_amounts.should =~ [Money.new(123_00), Money.new(456_00), Money.new(789_00)]
      end

      it 'associates the recoveries with the realisation statement' do
        realisation_statement = realisation_statement_received.realisation_statement
        recovery1.reload.realisation_statement.should == realisation_statement
        recovery2.reload.realisation_statement.should == realisation_statement
        recovery3.reload.realisation_statement.should == realisation_statement
      end
    end
  end
end
