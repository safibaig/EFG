class AddLegacyPremiumCalculationToPremiumSchedules < ActiveRecord::Migration
  def up
    add_column :premium_schedules, :legacy_premium_calculation, :boolean, default: false

    execute <<'SQL'
      update
        premium_schedules
      set
        legacy_premium_calculation = 1
SQL
  end

  def down
    remove_column :premium_schedules, :legacy_premium_calculation
  end
end
