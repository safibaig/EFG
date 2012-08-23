class LenderDefaultValues < ActiveRecord::Migration
  def up
    change_column_default :lenders, :high_volume, false
    change_column_null :lenders, :high_volume, false
    change_column_default :lenders, :can_use_add_cap, false
    change_column_null :lenders, :can_use_add_cap, false
  end

  def down
    change_column_null :lenders, :can_use_add_cap, true
    change_column_default :lenders, :can_use_add_cap, nil
    change_column_null :lenders, :high_volume, true
    change_column_default :lenders, :high_volume, nil
  end
end
