require 'spec_helper'

describe LoanTerm do

  let(:loan_term) { LoanTerm.new(loan) }

  context 'with loan category' do
    context 'and non-transferred loan' do
      let(:loan) { FactoryGirl.build(:loan, loan_category_id: 5) }

      describe '#min_months' do
        it "should return minimum number of loans months based on loan category minimum term months" do
          loan_term.min_months.should == 3
        end
      end

      describe '#max_months' do
        it "should return maximum number of loans months based on loan category minimum term months" do
          loan_term.max_months.should == 24
        end
      end
    end
  end

  context 'without loan category' do
    context 'and SFLG loan' do
      let(:loan) { FactoryGirl.build(:loan, :sflg, loan_category_id: nil) }

      context 'without loan category' do
        describe '#min_months' do
          it "should return default minimum number of loans months for SFLG loan" do
            loan_term.min_months.should == 24
          end
        end

        describe '#max_months' do
          it "should return default maximum number of loans months for SFLG loan" do
            loan_term.max_months.should == 120
          end
        end
      end
    end

    context 'and EFG loan' do
      let(:loan) { FactoryGirl.build(:loan, loan_category_id: nil) }

      context 'without loan category' do
        describe '#min_months' do
          it "should return default minimum number of loans months for EFG loan" do
            loan_term.min_months.should == 3
          end
        end

        describe '#max_months' do
          it "should return default maximum number of loans months for SFLG loan" do
            loan_term.max_months.should == 120
          end
        end
      end
    end
  end

  context 'with transferred loan' do
    let(:loan) { FactoryGirl.build(:loan, :transferred) }

    describe '#min_months' do
      it "should return 0 transferred loans have no start date limit" do
        loan_term.min_months.should == 0
      end
    end

    describe '#max_months' do
      it "should return default maximum number of loans months for EFG loan" do
        loan_term.max_months.should == 120
      end
    end
  end

end
