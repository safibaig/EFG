class DefaultRecoveriesToNotYetRealised < ActiveRecord::Migration
  def up
    change_column_default :recoveries, :realise_flag, false
    change_column_null :recoveries, :realise_flag, false
  end

  def down
    change_column_null :recoveries, :realise_flag, true
    change_column_default :recoveries, :realise_flag, nil
  end
end
