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

      it 'requires a collection_month' do
        premium_schedule_report.collection_month = ''
        premium_schedule_report.should_not be_valid
        premium_schedule_report.collection_month = '1/2012'
        premium_schedule_report.should be_valid
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
    let!(:loan1) { FactoryGirl.create(:loan) }
    let!(:loan2) { FactoryGirl.create(:loan, reference: 'ABC') }

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

    context 'with a loan reference' do
      it do
        premium_schedule_report.loan_reference = 'ABC'
        premium_schedule_report.loans.should_not include(loan1)
        premium_schedule_report.loans.should include(loan2)
      end
    end
  end

  describe '#to_csv' do
    let!(:loan) {
      FactoryGirl.create(:loan,
        lender: FactoryGirl.create(:lender, organisation_reference_code: 'Z'),
        reference: 'ABC'
      )
    }

    let(:premium_schedule_report) { PremiumScheduleReport.new }
    let(:csv) { CSV.parse(premium_schedule_report.to_csv) }

    it do
      csv.length.should == 2
    end

    context 'data' do
      let(:row) { csv[1] }

      it do
        row[1].should == 'Z'
        row[2].should == 'ABC'
      end
    end
  end
end
