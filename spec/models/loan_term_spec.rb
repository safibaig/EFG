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

  describe '#earliest_start_date' do
    let(:loan) { FactoryGirl.build(:loan) }

    it 'should return date 3 months from today' do
      loan_term.earliest_start_date.should == Date.today.advance(months: 3)
    end
  end

  describe '#latest_end_date' do
    let(:loan) { FactoryGirl.build(:loan) }

    it "should return date 120 months from today" do
      loan_term.latest_end_date.should == Date.today.advance(months: 120)
    end
  end

  describe "#months_between_draw_date_and_maturity_date" do

    context 'with loan term of several years' do
      let!(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2020, 3, 1)) }

      before do
        loan.initial_draw_change.update_attribute(:date_of_change, Date.new(2012, 2, 29))
      end

      it "should return the number of months from the initial draw date to the maturity date" do
        loan_term.months_between_draw_date_and_maturity_date.should eql(97)
      end
    end

    context 'with loan term of one year' do
      let!(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2013, 1, 31)) }

      before do
        loan.initial_draw_change.update_attribute(:date_of_change, Date.new(2012, 1, 31))
      end

      it "should return the number of months from the initial draw date to the maturity date" do
        loan_term.months_between_draw_date_and_maturity_date.should eql(12)
      end
    end

    context 'with loan term of one year, 1 day' do
      let!(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2013, 2, 1)) }

      before do
        loan.initial_draw_change.update_attribute(:date_of_change, Date.new(2012, 1, 31))
      end

      it "should return the number of months from the initial draw date to the maturity date" do
        loan_term.months_between_draw_date_and_maturity_date.should eql(13)
      end
    end

    context 'with loan term of 364 days' do
      let!(:loan) { FactoryGirl.create(:loan, :guaranteed, maturity_date: Date.new(2013, 1, 19)) }

      before do
        loan.initial_draw_change.update_attribute(:date_of_change, Date.new(2012, 1, 20))
      end

      it "should return the number of months from the initial draw date to the maturity date" do
        loan_term.months_between_draw_date_and_maturity_date.should eql(12)
      end
    end
  end

end
