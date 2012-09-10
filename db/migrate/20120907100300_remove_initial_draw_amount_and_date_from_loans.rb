class RemoveInitialDrawAmountAndDateFromLoans < ActiveRecord::Migration
  def up
    remove_column :loans, :initial_draw_amount
    remove_column :loans, :initial_draw_date
  end

  def down
    add_column :loans, :initial_draw_date, :date
    add_column :loans, :initial_draw_amount, :integer, limit: 8
  end
end
