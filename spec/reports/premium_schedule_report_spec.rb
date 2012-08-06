require 'spec_helper'

describe PremiumScheduleReport do
  describe 'validations' do
    let(:premium_schedule_report) { PremiumScheduleReport.new }

    it 'is invalid with nothing set' do
      premium_schedule_report.should_not be_valid
    end

    context '#loan_reference' do
      it 'makes everything good' do
        premium_schedule_report.loan_reference = 'ABC'
        premium_schedule_report.should be_valid
      end
    end

    context '#collection_month' do
      it 'must be in the correct format' do
        premium_schedule_report.loan_reference = 'ABC'
        premium_schedule_report.should be_valid
        premium_schedule_report.collection_month = 'zzz'
        premium_schedule_report.should_not be_valid
      end
    end

    context 'schedule_type "All"' do
      before do
        premium_schedule_report.schedule_type = 'All'
      end

      context 'with a collection_month' do
        before do
          premium_schedule_report.collection_month = '1/2012'
        end

        it 'is not valid without a start_on or finish_on' do
          premium_schedule_report.should_not be_valid
        end

        it 'is valid with a start_on (or finish_on)' do
          premium_schedule_report.start_on = '1/1/11'
          premium_schedule_report.should be_valid
        end

        it 'is valid with a finish_on (or start_on)' do
          premium_schedule_report.finish_on = '1/1/11'
          premium_schedule_report.should be_valid
        end
      end

      context 'with a start_on' do
        before do
          premium_schedule_report.start_on = '1/1/11'
        end

        it 'is not valid without a collection_month' do
          premium_schedule_report.should_not be_valid
        end

        it 'is valid with a collection_month' do
          premium_schedule_report.collection_month = '1/2012'
          premium_schedule_report.should be_valid
        end
      end

      context 'with a finish_on' do
        before do
          premium_schedule_report.finish_on = '1/1/11'
        end

        it 'is not valid without a collection_month' do
          premium_schedule_report.should_not be_valid
        end

        it 'is valid with a collection_month' do
          premium_schedule_report.collection_month = '1/2012'
          premium_schedule_report.should be_valid
        end
      end
    end

    context 'schedule_type "Changed"' do
      before do
        premium_schedule_report.schedule_type = 'Changed'
      end

      it 'is invalid without a collection_month' do
        premium_schedule_report.should_not be_valid
      end

      it 'is valid with a collection_month' do
        premium_schedule_report.collection_month = '1/2012'
        premium_schedule_report.should be_valid
      end

      it 'cannot have start_on' do
        premium_schedule_report.collection_month = '1/2012'
        premium_schedule_report.start_on = '1/1/11'
        premium_schedule_report.should_not be_valid
      end

      it 'cannot have finish_on' do
        premium_schedule_report.collection_month = '1/2012'
        premium_schedule_report.finish_on = '1/1/11'
        premium_schedule_report.should_not be_valid
      end
    end

    context 'schedule_type "New"' do
      before do
        premium_schedule_report.schedule_type = 'New'
      end

      it 'is invalid without a start_on or finish_on' do
        premium_schedule_report.should_not be_valid
      end

      it 'requires start_on (or finish_on)' do
        premium_schedule_report.start_on = '1/1/11'
        premium_schedule_report.should be_valid
      end

      it 'requires finish_on (or start_on)' do
        premium_schedule_report.finish_on = '1/1/11'
        premium_schedule_report.should be_valid
      end
    end
  end

  describe '#loans' do
    let(:premium_schedule_report) { PremiumScheduleReport.new }
    let(:loan1) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'E', loan_source: 'L') }
    let(:loan2) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'E', loan_source: 'S', reference: 'ABC') }
    let(:loan3) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'S', loan_source: 'S') }
    let!(:state_aid_calculation1) { FactoryGirl.create(:state_aid_calculation, loan: loan1, calc_type: 'S') }
    let!(:state_aid_calculation2) { FactoryGirl.create(:state_aid_calculation, loan: loan2, calc_type: 'R') }
    let!(:state_aid_calculation3) { FactoryGirl.create(:state_aid_calculation, loan: loan3, calc_type: 'N') }
    let!(:loan_change_1) { FactoryGirl.create(:loan_change, loan: loan1, date_of_change: '1/1/11') }
    let!(:loan_change_2) { FactoryGirl.create(:loan_change, loan: loan2, date_of_change: '2/1/11') }
    let!(:loan_change_3) { FactoryGirl.create(:loan_change, loan: loan3, date_of_change: '3/1/11') }

    let(:loan_ids) { premium_schedule_report.loans.map(&:id) }

    it 'returns the loans' do
      loan_ids.should include(loan1.id)
      loan_ids.should include(loan2.id)
      loan_ids.should include(loan3.id)
    end

    context 'with schedule_type' do
      it do
        premium_schedule_report.schedule_type = 'All'
        loan_ids.length.should == 3
      end

      context '"New"' do
        before do
          FactoryGirl.create(:loan_change, loan: loan1, date_of_change: '11/2/2011')
          FactoryGirl.create(:loan_change, loan: loan3, date_of_change: '12/2/2011')

          premium_schedule_report.schedule_type = 'New'
        end

        it do
          loan_ids.should include(loan1.id)
          loan_ids.should_not include(loan2.id)
          loan_ids.should include(loan3.id)
        end

        it 'pulls the draw_down_date from the first loan_change' do
          premium_schedule_report.loans.first._draw_down_date.should == Date.new(2011, 1, 1)
          premium_schedule_report.loans.last._draw_down_date.should == Date.new(2011, 1, 3)
        end

        it 'pulls the guaranteed_date from the first loan_change' do
          premium_schedule_report.loans.first._guaranteed_date.should == Date.new(2011, 1, 1)
          premium_schedule_report.loans.last._guaranteed_date.should == Date.new(2011, 1, 3)
        end
      end

      context '"Changed"' do
        before do
          FactoryGirl.create(:loan_change, loan: loan2, date_of_change: '2/3/2012')
          FactoryGirl.create(:loan_change, loan: loan2, date_of_change: '3/3/2012')

          premium_schedule_report.schedule_type = 'Changed'
        end

        it do
          loan_ids.should_not include(loan1.id)
          loan_ids.should include(loan2.id)
          loan_ids.should_not include(loan3.id)
        end

        it 'pulls the draw_down_date from the first loan_change' do
          premium_schedule_report.loans.first._draw_down_date.should == Date.new(2011, 1, 2)
        end

        it 'pulls the guaranteed_date from the last loan_change' do
          premium_schedule_report.loans.first._guaranteed_date.should == Date.new(2012, 3, 3)
        end
      end
    end

    context 'with a lender_id' do
      it 'includes only loans from that lender' do
        premium_schedule_report.lender_id = loan1.lender_id
        premium_schedule_report.loans.should include(loan1)
        premium_schedule_report.loans.should_not include(loan2)
        premium_schedule_report.loans.should_not include(loan3)
      end
    end

    context 'with a loan_reference' do
      it do
        premium_schedule_report.loan_reference = 'ABC'
        premium_schedule_report.loans.should_not include(loan1)
        premium_schedule_report.loans.should include(loan2)
        premium_schedule_report.loans.should_not include(loan3)
      end
    end

    context 'with a loan_scheme' do
      it do
        premium_schedule_report.loan_scheme = 'All'
        premium_schedule_report.loans.length.should == 3
      end

      it do
        premium_schedule_report.loan_scheme = 'SFLG Only'
        premium_schedule_report.loans.should_not include(loan1)
        premium_schedule_report.loans.should_not include(loan2)
        premium_schedule_report.loans.should include(loan3)
      end

      it do
        premium_schedule_report.loan_scheme = 'EFG Only'
        premium_schedule_report.loans.should include(loan1)
        premium_schedule_report.loans.should include(loan2)
        premium_schedule_report.loans.should_not include(loan3)
      end
    end

    context 'with a loan_type' do
      it do
        premium_schedule_report.loan_type = 'All'
        premium_schedule_report.loans.length.should == 3
      end

      it do
        premium_schedule_report.loan_type = 'New'
        premium_schedule_report.loans.should_not include(loan1)
        premium_schedule_report.loans.should include(loan2)
        premium_schedule_report.loans.should include(loan3)
      end

      it do
        premium_schedule_report.loan_type = 'Legacy'
        premium_schedule_report.loans.should include(loan1)
        premium_schedule_report.loans.should_not include(loan2)
        premium_schedule_report.loans.should_not include(loan3)
      end
    end
  end

  describe '#to_csv' do
    let(:lender) { FactoryGirl.create(:lender, organisation_reference_code: 'Z') }
    let(:loan) { FactoryGirl.create(:loan, lender: lender, reference: 'ABC') }

    before do
      FactoryGirl.create(:loan_change, loan: loan, date_of_change: '3/11/2011')
      FactoryGirl.create(:state_aid_calculation, loan: loan, calc_type: 'S')
    end

    let(:premium_schedule_report) { PremiumScheduleReport.new }

    it 'works' do
      csv = CSV.parse(premium_schedule_report.to_csv)
      csv.length.should == 2

      row = csv[1]
      row[0].should == '03-11-2011'
      row[1].should == 'Z'
      row[2].should == 'ABC'
      row[3].should == 'S'
      row[4].should == '61.72'

      row[6].should == '3'
      row[7].should == '0.0'
      row[8].should == '46.29'
      row[9].should == '30.86'
      row[10].should == '15.43'
      row[11].should == '0.0'
      row[12].should == '0.0'
      row[13].should == '0.0'
      row[14].should == '0.0'
      row[15].should == '0.0'
      row[16].should == '0.0'
      row[17].should == '0.0'
      row[18].should == '0.0'
      row[19].should == '0.0'
      row[20].should == '0.0'
      row[21].should == '0.0'
      row[22].should == '0.0'
      row[23].should == '0.0'
      row[24].should == '0.0'
      row[25].should == '0.0'
      row[26].should == '0.0'
      row[27].should == '0.0'
      row[28].should == '0.0'
      row[29].should == '0.0'
      row[30].should == '0.0'
      row[31].should == '0.0'
      row[32].should == '0.0'
      row[33].should == '0.0'
      row[34].should == '0.0'
      row[35].should == '0.0'
      row[36].should == '0.0'
      row[37].should == '0.0'
      row[38].should == '0.0'
      row[39].should == '0.0'
      row[40].should == '0.0'
      row[41].should == '0.0'
      row[42].should == '0.0'
      row[43].should == '0.0'
      row[44].should == '0.0'
      row[45].should == '0.0'
      row[46].should == '0.0'
    end
  end
end
