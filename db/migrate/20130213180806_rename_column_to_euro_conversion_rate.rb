class RenameColumnToEuroConversionRate < ActiveRecord::Migration
  def up
    rename_column :state_aid_calculations, :euro_conv_rate, :euro_conversion_rate
  end

  def down
    rename_column :state_aid_calculations, :euro_conversion_rate, :euro_conv_rate
  end
end