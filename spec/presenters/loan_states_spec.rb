require 'spec_helper'

describe LoanStates do

  describe "#states" do
    let!(:lender) { FactoryGirl.create(:lender) }

    let(:loan_states) { LoanStates.new(lender).states }

    before(:each) do
      # guaranteed loans
      FactoryGirl.create(:loan, :guaranteed, :legacy_sflg, lender: lender)
      FactoryGirl.create(:loan, :guaranteed, :sflg, lender: lender)
      FactoryGirl.create(:loan, :guaranteed, lender: lender)

      # demanded loans
      FactoryGirl.create(:loan, :demanded, :legacy_sflg, lender: lender)
      FactoryGirl.create(:loan, :demanded, :legacy_sflg, lender: lender)
      FactoryGirl.create(:loan, :demanded, lender: lender)
      FactoryGirl.create(:loan, :demanded, lender: lender)
    end

    it "should return loans grouped by state" do
      loan_states.size.should == 2
      loan_states.first.state.should == Loan::Guaranteed
      loan_states.last.state.should == Loan::Demanded
    end

    it "should have legacy sflg loan count" do
      loan_states.first.legacy_sflg_loans_count.should == 1
      loan_states.last.legacy_sflg_loans_count.should == 2
    end

    it "should have sflg loan count" do
      loan_states.first.sflg_loans_count.should == 1
      loan_states.last.sflg_loans_count.should == 0
    end

    it "should have efg loan count" do
      loan_states.first.efg_loans_count.should == 1
      loan_states.last.efg_loans_count.should == 2
    end

    it "should have total loans count" do
      loan_states.first.total_loans.should == 3
      loan_states.last.total_loans.should == 4
    end
  end

end
