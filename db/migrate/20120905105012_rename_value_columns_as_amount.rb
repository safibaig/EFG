class RenameValueColumnsAsAmount < ActiveRecord::Migration
  def change
    rename_column :loans, :initial_draw_value, :initial_draw_amount
    rename_column :loans, :current_refinanced_value, :current_refinanced_amount
    rename_column :loans, :final_refinanced_value, :final_refinanced_amount
  end
end
