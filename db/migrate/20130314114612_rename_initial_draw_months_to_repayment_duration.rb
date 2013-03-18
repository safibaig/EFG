class RenameInitialDrawMonthsToRepaymentDuration < ActiveRecord::Migration
  def up
    rename_column :premium_schedules, :initial_draw_months, :repayment_duration
  end

  def down
    rename_column :premium_schedules, :repayment_duration, :initial_draw_months
  end
end
