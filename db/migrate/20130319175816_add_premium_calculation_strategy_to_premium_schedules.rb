class AddPremiumCalculationStrategyToPremiumSchedules < ActiveRecord::Migration
  def up
    add_column :premium_schedules, :premium_calculation_strategy, :string

    execute <<'SQL'
      update
        premium_schedules
      set
        premium_calculation_strategy = 'legacy_quarterly'
      where
        premium_calculation_strategy is null
SQL
  end

  def down
    remove_column :premium_schedules, :premium_calculation_strategy
  end
end
