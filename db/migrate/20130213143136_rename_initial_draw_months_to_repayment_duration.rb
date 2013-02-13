class RenameInitialDrawMonthsToRepaymentDuration < ActiveRecord::Migration
  def up
    rename_column :state_aid_calculations, :initial_draw_months, :repayment_duration
  end

  def down
    rename_column :state_aid_calculations, :repayment_duration, :initial_draw_months
  end
end
