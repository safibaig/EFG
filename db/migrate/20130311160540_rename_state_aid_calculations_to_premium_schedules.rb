class RenameStateAidCalculationsToPremiumSchedules < ActiveRecord::Migration
  def up
    rename_table :state_aid_calculations, :premium_schedules
    rename_index :premium_schedules, 'index_state_aid_calculations_on_legacy_loan_id', 'index_premium_schedules_on_legacy_loan_id'
    rename_index :premium_schedules, 'index_state_aid_calculations_on_loan_id_and_seq', 'index_premium_schedules_on_loan_id_and_seq'
  end

  def down
    rename_table :premium_schedules, :state_aid_calculations
    rename_index :state_aid_calculations, 'index_premium_schedules_on_legacy_loan_id', 'index_state_aid_calculations_on_legacy_loan_id'
    rename_index :state_aid_calculations, 'index_premium_schedules_on_loan_id_and_seq', 'index_state_aid_calculations_on_loan_id_and_seq'
  end
end
