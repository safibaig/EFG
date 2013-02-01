class AddPhaseToLendingLimits < ActiveRecord::Migration
  def change
    add_column :lending_limits, :phase_id, :integer
    add_index :lending_limits, :phase_id
  end
end