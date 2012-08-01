require 'spec_helper'

describe PremiumScheduleReport do
  describe 'validations' do
    let(:premium_schedule_report) { FactoryGirl.build(:premium_schedule_report) }

    it 'has a valid factory' do
      premium_schedule_report.should be_valid
    end

    context '#collection_month' do
      it 'must be in the correct format' do
        premium_schedule_report.collection_month = 'zzz'
        premium_schedule_report.should_not be_valid
      end

      it 'must be present if schedule_type is "All"' do
        premium_schedule_report.collection_month = ''
        premium_schedule_report.schedule_type = 'All'
        premium_schedule_report.should_not be_valid
      end

      it 'must be present if schedule_type is "Changed"' do
        premium_schedule_report.collection_month = ''
        premium_schedule_report.schedule_type = 'Changed'
        premium_schedule_report.should_not be_valid
      end

      it 'must be present when there is no loan_reference' do
        premium_schedule_report.collection_month = ''
        premium_schedule_report.loan_reference = ''
        premium_schedule_report.should_not be_valid
      end

      it 'can be blank when schedule_type is "New" and a start_on is present' do
        premium_schedule_report.collection_month = ''
        premium_schedule_report.start_on = '1/1/12'
        premium_schedule_report.schedule_type = 'New'
        premium_schedule_report.should be_valid
      end
    end

    context '#finish_on / #start_on' do
      %w(All New).each do |schedule_type|
        context "with schedule_type #{schedule_type.inspect}" do
          before do
            premium_schedule_report.schedule_type = schedule_type
          end

          it 'is invalid without either' do
            premium_schedule_report.finish_on = ''
            premium_schedule_report.start_on = ''
            premium_schedule_report.should_not be_valid
          end

          it 'is valid with finish_on' do
            premium_schedule_report.finish_on = '1/1/11'
            premium_schedule_report.start_on = ''
            premium_schedule_report.should be_valid
          end

          it 'is valid with start_on' do
            premium_schedule_report.finish_on = ''
            premium_schedule_report.start_on = '1/1/11'
            premium_schedule_report.should be_valid
          end
        end
      end
    end
  end

  describe '#loans' do
    let(:premium_schedule_report) { PremiumScheduleReport.new }
    let!(:loan1) { FactoryGirl.create(:loan) }
    let!(:loan2) { FactoryGirl.create(:loan) }

    it 'returns the loans' do
      premium_schedule_report.loans.should include(loan1)
      premium_schedule_report.loans.should include(loan2)
    end

    context 'with a lender_id' do
      it 'includes only loans from that lender' do
        premium_schedule_report.lender_id = loan1.lender_id
        premium_schedule_report.loans.should include(loan1)
        premium_schedule_report.loans.should_not include(loan2)
      end
    end
  end
end
