require 'spec_helper'
require 'importers'

describe StateAidCalculationImporter do
  describe '.import' do
    let!(:loan1) { FactoryGirl.create(:loan, :eligible, legacy_id: 8819) }
    let!(:loan2) { FactoryGirl.create(:loan, :eligible, legacy_id: 65482) }

    let(:csv_fixture_path) { Rails.root.join('spec/fixtures/import_data/SFLG_CALCULATORS_DATA_TABLE.csv') }

    before do
      StateAidCalculationImporter.instance_variable_set(:@lender_id_from_legacy_id, nil)
    end

    def dispatch
      StateAidCalculationImporter.csv_path = csv_fixture_path
      StateAidCalculationImporter.import
    end

    it 'creates new state aid calculation records' do
      expect {
        dispatch
      }.to change(StateAidCalculation, :count).by(2)
    end

    it 'imports row 1' do
      dispatch

      state_aid_calculation = StateAidCalculation.first
      state_aid_calculation.loan.should == loan1
      # state_aid_calculation.legacy_loan_id.should == '8819'
      state_aid_calculation.seq.should == 0
      state_aid_calculation.loan_version.should == 0
      state_aid_calculation.calc_type.should == 'S'
      state_aid_calculation.initial_draw_year.should == 2006
      state_aid_calculation.premium_cheque_month.should == ''
      state_aid_calculation.initial_draw_amount.should == Money.new(25_425_00)
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

    it 'imports row 2' do
      dispatch

      state_aid_calculation = StateAidCalculation.last
      state_aid_calculation.loan.should == loan2
      # state_aid_calculation.legacy_loan_id.should == '65482'
      state_aid_calculation.seq.should == 1
      state_aid_calculation.loan_version.should == 1
      state_aid_calculation.calc_type.should == 'R'
      state_aid_calculation.initial_draw_year.should be_nil
      state_aid_calculation.premium_cheque_month.should == '07/2007'
      state_aid_calculation.initial_draw_amount.should == Money.new(67_187_50)
      state_aid_calculation.initial_draw_months.should == 43
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
      state_aid_calculation.guarantee_rate.should == 85
      state_aid_calculation.npv.should == BigDecimal.new('3.5')
      state_aid_calculation.prem_rate.should == BigDecimal.new('1.5')
      state_aid_calculation.euro_conv_rate.should == BigDecimal.new('1.48214')
      state_aid_calculation.elsewhere_perc.should == 40
      state_aid_calculation.obj1_perc.should == 60
      state_aid_calculation.ar_timestamp.should be_nil
      state_aid_calculation.ar_insert_timestamp.should be_nil
    end
  end
end
