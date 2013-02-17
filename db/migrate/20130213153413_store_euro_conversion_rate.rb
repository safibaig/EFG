class StoreEuroConversionRate < ActiveRecord::Migration
  def up
    execute "UPDATE `state_aid_calculations` SET `euro_conv_rate` = 1.1974 WHERE `state_aid_calculations`.`euro_conv_rate` IS NULL"
    change_column :state_aid_calculations, :euro_conv_rate, :decimal, precision: 17, scale: 14, null: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end