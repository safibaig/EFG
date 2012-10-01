class DefaultLendersAllowAlertProcessToTrue < ActiveRecord::Migration
  def up
    change_column :lenders, :allow_alert_process, :boolean, default: true
  end

  def down
    change_column :lenders, :allow_alert_process, :boolean, default: false
  end
end
