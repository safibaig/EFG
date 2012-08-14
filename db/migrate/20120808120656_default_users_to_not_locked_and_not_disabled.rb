class DefaultUsersToNotLockedAndNotDisabled < ActiveRecord::Migration
  def up
    change_column_default :users, :locked, false
    change_column_null :users, :locked, false
    change_column_default :users, :disabled, false
    change_column_null :users, :disabled, false
  end

  def down
    change_column_null :users, :locked, true
    change_column_default :users, :locked, nil
    change_column_null :users, :disabled, true
    change_column_default :users, :disabled, nil
  end
end
