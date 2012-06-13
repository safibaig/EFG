require 'spec_helper'
require 'importers'

describe StateAidCalculationImporter do
  describe '.import' do
    let!(:loan) { FactoryGirl.create(:loan, :eligible, id: 8819) }
    let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_CALCULATORS_DATA_TABLE.csv') }

    def dispatch
      StateAidCalculationImporter.csv_path = csv_fixture_path
      StateAidCalculationImporter.import
    end

    it 'creates new user records' do
      expect {
        dispatch
      }.to change(StateAidCalculation, :count).by(1)
    end

    it 'should import data correctly' do
      dispatch

      state_aid_calculation = StateAidCalculation.last
      state_aid_calculation.loan.should == loan
      state_aid_calculation.legacy_id.should == '8819'
      state_aid_calculation.seq.should == 0
      state_aid_calculation.loan_version.should == 0
      state_aid_calculation.calc_type.should == 'S'
      state_aid_calculation.initial_draw_year.should == 2006
      state_aid_calculation.premium_cheque_month.should == ''
      state_aid_calculation.initial_draw_amount.should == 25425
      state_aid_calculation.initial_draw_months.should == 84
      state_aid_calculation.initial_capital_repayment_holiday.should == 0
      state_aid_calculation.second_draw_amount.should be_nil
      state_aid_calculation.second_draw_months.should be_nil
      state_aid_calculation.third_draw_amount.should be_nil
      state_aid_calculation.third_draw_months.should be_nil
      state_aid_calculation.fourth_draw_amount.should be_nil
      state_aid_calculation.fourth_draw_months.should be_nil
      state_aid_calculation.total_cost.should == 0
      state_aid_calculation.public_funding.should == 0
      state_aid_calculation.obj1_area.should == false
      state_aid_calculation.reduce_costs.should == false
      state_aid_calculation.improve_prod.should == false
      state_aid_calculation.increase_quality.should == false
      state_aid_calculation.improve_nat_env.should == false
      state_aid_calculation.promote.should == false
      state_aid_calculation.agriculture.should == false
      state_aid_calculation.guarantee_rate.should == 75
      state_aid_calculation.npv.should == BigDecimal.new('3.5')
      state_aid_calculation.prem_rate.should == BigDecimal.new('2')
      state_aid_calculation.euro_conv_rate.should == BigDecimal.new('1.60849284220685')
      state_aid_calculation.elsewhere_perc.should == 40
      state_aid_calculation.obj1_perc.should == 60
      state_aid_calculation.ar_timestamp.should == Time.gm(2006, 10, 6)
      state_aid_calculation.ar_insert_timestamp.should == Time.gm(2006, 10, 6)
    end
  end
end
