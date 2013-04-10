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

      it 'cannot have collection_month' do
        premium_schedule_report.start_on = '1/1/11'
        premium_schedule_report.collection_month = '01/2011'
        premium_schedule_report.should_not be_valid
      end
    end
  end

  describe '#loans' do
    let(:premium_schedule_report) { PremiumScheduleReport.new }
    let(:loan1) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'E', loan_source: 'L') }
    let(:loan2) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'E', loan_source: 'S', reference: 'ABC') }
    let(:loan3) { FactoryGirl.create(:loan, :guaranteed, loan_scheme: 'S', loan_source: 'S') }
    let!(:premium_schedule1) { FactoryGirl.create(:premium_schedule, loan: loan1, calc_type: 'S', premium_cheque_month: '01/2011') }
    let!(:premium_schedule2) { FactoryGirl.create(:premium_schedule, loan: loan2, calc_type: 'R', premium_cheque_month: "01/#{Date.today.year + 1}") }
    let!(:premium_schedule3) { FactoryGirl.create(:premium_schedule, loan: loan3, calc_type: 'N', premium_cheque_month: '02/2011') }

    before do
      loan1.initial_draw_change.update_attribute :date_of_change, '1/1/11'
      loan2.initial_draw_change.update_attribute :date_of_change, '2/1/11'
      loan3.initial_draw_change.update_attribute :date_of_change, '3/1/11'

      loan1.initial_draw_change.update_attribute :modified_date, '1/1/11'
      loan2.initial_draw_change.update_attribute :modified_date, '2/1/11'
      loan3.initial_draw_change.update_attribute :modified_date, '3/1/11'
    end

    let(:loan_ids) { premium_schedule_report.loans.map(&:id) }

    it 'returns the loans' do
      loan_ids.should include(loan1.id)
      loan_ids.should include(loan2.id)
      loan_ids.should include(loan3.id)
    end

    context 'with combination of conditions' do
      it do
        premium_schedule_report.loan_type = 'Legacy'
        premium_schedule_report.loan_scheme = 'EFG only'
        premium_schedule_report.schedule_type = 'All'
        premium_schedule_report.collection_month = '01/2011'
        premium_schedule_report.start_on = '01/01/2011'

        premium_schedule_report.should be_valid
        loan_ids.should == [ loan1.id ]
      end
    end

    context 'with schedule_type' do
      it do
        premium_schedule_report.schedule_type = 'All'
        loan_ids.length.should == 3
      end

      context '"New"' do
        before do
          premium_schedule_report.schedule_type = 'New'
        end

        context 'draw_down_date' do
          before do
            FactoryGirl.create(:loan_change, loan: loan1, date_of_change: '11/2/2011')
            FactoryGirl.create(:loan_change, loan: loan3, date_of_change: '12/2/2011')
          end

          it do
            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should include(loan3.id)
          end

          it 'pulls the draw_down_date from the first loan_change' do
            premium_schedule_report.loans.first.draw_down_date.should == Date.new(2011, 1, 1)
            premium_schedule_report.loans.last.draw_down_date.should == Date.new(2011, 1, 3)
          end
        end

        context 'with start_on / finish_on' do
          it do
            premium_schedule_report.start_on = '1/1/2011'

            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should include(loan3.id)
          end

          it do
            premium_schedule_report.start_on = '1/1/2011'
            premium_schedule_report.finish_on = '1/1/2011'

            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should_not include(loan3.id)
          end

          it do
            premium_schedule_report.start_on = '1/1/2011'
            premium_schedule_report.finish_on = '2/1/2011'

            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should_not include(loan3.id)
          end

          it do
            premium_schedule_report.start_on = '2/1/2011'

            loan_ids.should_not include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should include(loan3.id)
          end

          it do
            premium_schedule_report.finish_on = '3/1/2011'

            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should include(loan3.id)
          end

          it do
            premium_schedule_report.finish_on = '1/1/2011'

            loan_ids.should include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should_not include(loan3.id)
          end
        end
      end

      context '"Changed"' do
        before do
          premium_schedule_report.schedule_type = 'Changed'
        end

        it do
          loan_ids.should_not include(loan1.id)
          loan_ids.should include(loan2.id)
          loan_ids.should_not include(loan3.id)
        end

        it 'includes all rescheduled loans' do
          FactoryGirl.create(:premium_schedule, loan: loan1, calc_type: 'R', premium_cheque_month: "03/#{Date.today.year + 1}")
          FactoryGirl.create(:premium_schedule, loan: loan3, calc_type: 'R', premium_cheque_month: "03/#{Date.today.year + 1}")

          loan_ids.should include(loan1.id)
          loan_ids.should include(loan2.id)
          loan_ids.should include(loan3.id)
        end

        context 'draw_down_date' do
          before do
            FactoryGirl.create(:loan_change, loan: loan2, date_of_change: '2/3/2012')
            FactoryGirl.create(:loan_change, loan: loan2, date_of_change: '3/3/2012')
          end

          it 'pulls the draw_down_date from the first loan_change' do
            premium_schedule_report.loans.first.draw_down_date.should == Date.new(2011, 1, 2)
          end
        end

        context 'with collection_month' do
          before do
            FactoryGirl.create(:premium_schedule, loan: loan1, calc_type: 'R', premium_cheque_month: "04/#{Date.today.year + 1}")
            FactoryGirl.create(:premium_schedule, loan: loan2, calc_type: 'R', premium_cheque_month: "04/#{Date.today.year + 1}")
            FactoryGirl.create(:premium_schedule, loan: loan3, calc_type: 'R', premium_cheque_month: "05/#{Date.today.year + 1}")
          end

          it do
            premium_schedule_report.collection_month = "04/#{Date.today.year + 1}"

            loan_ids.should include(loan1.id)
            loan_ids.should include(loan2.id)
            loan_ids.should_not include(loan3.id)
          end

          it do
            premium_schedule_report.collection_month = "04/#{Date.today.year + 2}"

            loan_ids.should_not include(loan1.id)
            loan_ids.should_not include(loan2.id)
            loan_ids.should_not include(loan3.id)
          end
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
    let!(:lender) { FactoryGirl.create(:lender, organisation_reference_code: 'Z') }

    let!(:loan) { FactoryGirl.create(:loan, lender: lender, reference: 'ABC') }

    let(:premium_schedule_report) { PremiumScheduleReport.new }

    let(:csv) { CSV.parse(premium_schedule_report.to_csv) }

    let(:row) { csv[1] }

    before do
      FactoryGirl.create(:loan_change, loan: loan, date_of_change: '3/11/2011')
    end

    context 'with standard state aid calculation' do

      before do
        FactoryGirl.create(:premium_schedule, loan: loan, calc_type: 'S', premium_cheque_month: '2/2011')
      end

      it 'should return 2 rows of data' do
        csv.length.should == 2
      end

      it 'should return loan premium schedule details' do
        row[0].should == '03-11-2011'
        row[1].should == 'Z'
        row[2].should == 'ABC'
        row[3].should == 'S'
        row[4].should == '61.72'
        row[5].should == '2/2011'
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

    context 'with rescheduled state aid calculation' do
      before do
        FactoryGirl.create(:rescheduled_premium_schedule, loan: loan)
      end

      it 'sets schedule type correctly' do
        row[3].should == 'R'
      end

      it 'includes first premium amount' do
        row[7].should == '61.72'
      end
    end

    context "with state aid calculation without premium cheque month" do
      before do
        premium_schedule = FactoryGirl.create(:premium_schedule, loan: loan)
        premium_schedule.update_attribute(:premium_cheque_month, "")
      end

      it 'sets first collection date to 3 months after guarantee date' do
        row[5].should == "02/2012"
      end
    end

    context "where loan has scheduled and re-scheduled state aid calculations" do
      let!(:scheduled_premium_schedule) { FactoryGirl.create(:premium_schedule, loan: loan) }
      let!(:rescheduled_premium_schedule) { FactoryGirl.create(:rescheduled_premium_schedule, loan: loan) }

      let(:row1) { csv[1] }
      let(:row2) { csv[2] }

      it "should include a row for both state aid calculations" do
        csv.length.should == 3
      end

      it "should set the correct calc type for scheduled state aid calculation" do
        row1[3].should == 'S'
      end

      it "should set the correct premiums for scheduled state aid calculation" do
        # the first premium is set to 0.0 for premium schedules with calc type 'S'
        expected_premiums = scheduled_premium_schedule.premiums.collect { |p| p.to_f.to_s }
        expected_premiums[0] = "0.0"

        row1[7, expected_premiums.size].should == expected_premiums
      end

      it "should set the correct calc type for re-scheduled state aid calculation" do
        row2[3].should == 'R'
      end

      it "should set the correct premiums for re-scheduled state aid calculation" do
        expected_premiums = rescheduled_premium_schedule.premiums.collect { |p| p.to_f.to_s }

        row2[7, expected_premiums.size].should == expected_premiums
      end
    end

    context "with Notified Aid calc type" do
      before do
        FactoryGirl.create(:premium_schedule, loan: loan, calc_type: PremiumSchedule::NOTIFIED_AID_TYPE)
      end

      it "sets Schedule Type value to 'S' instead of 'N'" do
        row[3].should == 'S'
      end
    end

    context "with ZeroDivisionError raised in " do
      it "should log the output and the exception and the loan" do
        loan = double(inspect: '#<Loan id:1>')
        row = double(loan: loan)
        row.stub!(:to_csv).and_raise(ZeroDivisionError)
        PremiumScheduleReportRow.stub!(:from_loans).and_return([row])

        logger = double
        logger.should_receive(:error).with("PremiumScheduleReport Error: ZeroDivisionError reporting on #<Loan id:1>")
        Rails.stub!(:logger).and_return(logger)

        premium_schedule_report.to_csv
      end
    end

  end
end
