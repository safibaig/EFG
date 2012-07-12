require 'spec_helper'

describe RealisationStatement do
  let(:realisation_statement) { FactoryGirl.build(:realisation_statement) }

  describe "validations" do

    it 'should have a valid factory' do
      realisation_statement.should be_valid
    end

    it 'must have a lender' do
      realisation_statement.lender = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a created by user' do
      realisation_statement.created_by = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a reference' do
      realisation_statement.reference = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a period recovery quarter' do
      realisation_statement.period_covered_quarter = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period recovery quarter' do
      realisation_statement.period_covered_quarter = 'April'
      realisation_statement.should_not be_valid
    end

    it 'must have a period covered year' do
      realisation_statement.period_covered_year = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid period covered year' do
      realisation_statement.period_covered_year = '201'
      realisation_statement.should_not be_valid
    end

    it 'must have a received on date' do
      realisation_statement.received_on = nil
      realisation_statement.should_not be_valid
    end

    it 'must have a valid received on date' do
      realisation_statement.received_on = '2012-05-01'
      realisation_statement.should_not be_valid
    end

    it "must have loans to be realised" do
      realisation_statement.loans_to_be_realised_ids = []
      realisation_statement.should_not be_valid
    end

  end

  describe "#recovered_loans" do
    let!(:specified_quarter_recovered_loan) {
      FactoryGirl.create(:loan, :recovered, lender: realisation_statement.lender, recovery_on: Date.new(2012, 3, 31))
    }

    let!(:previous_quarter_recovered_loan) {
      FactoryGirl.create(:loan, :recovered, lender: realisation_statement.lender, recovery_on: Date.new(2011, 12, 31))
    }

    let!(:next_quarter_recovered_loan) {
      FactoryGirl.create(:loan, :recovered, lender: realisation_statement.lender, recovery_on: Date.new(2012, 6, 30))
    }

    it "should return recovered loans within or prior to the specified quarter" do
      realisation_statement.period_covered_quarter = 'March'
      realisation_statement.period_covered_year = '2012'

      loans = realisation_statement.recovered_loans

      loans.size.should == 2
      loans.should include(specified_quarter_recovered_loan)
      loans.should include(previous_quarter_recovered_loan)
    end
  end

  describe "#save" do

    let(:recovered_loan) { FactoryGirl.create(:loan, :recovered) }

    let(:settled_loan) { FactoryGirl.create(:loan, :settled) }

    context 'with invalid loans to be realised' do

      before(:each) do
        realisation_statement.loans_to_be_realised_ids = [ recovered_loan.id, settled_loan.id]
      end

      it 'raises exception when a loan to be realised is not in a Recovered state' do
        expect {
          realisation_statement.save
        }.to raise_error(LoanStateTransition::IncorrectLoanState)
      end

    end

    context 'with valid loans to be realised' do

      before(:each) do
        realisation_statement.loans_to_be_realised_ids = [ recovered_loan.id ]
        realisation_statement.save
      end

      it 'updates all loans to be realised to Realised state' do
        recovered_loan.reload.state.should == Loan::Realised
      end

      it 'creates loan realisation for each loan to be realised' do
        LoanRealisation.count.should == 1
      end

      it 'creates loan realisations with the same created by user as the realisation statement' do
        realisation_statement.loan_realisations.each do |loan_realisation|
          loan_realisation.created_by.should == realisation_statement.created_by
        end
      end

      it 'stores the realised amount on each new loan realisation' do
        pending
      end
    end
  end

end
