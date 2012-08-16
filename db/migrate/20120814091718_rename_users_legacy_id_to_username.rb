class RenameUsersLegacyIdToUsername < ActiveRecord::Migration
  def up
    execute 'UPDATE users SET legacy_id = CONCAT("user", id) WHERE legacy_id IS NULL'
    remove_index :users, :legacy_id
    rename_column :users, :legacy_id, :username
    change_column_null :users, :username, false
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    change_column_null :users, :username, true
    rename_column :users, :username, :legacy_id
    add_index :users, :legacy_id, unique: true
  end
end
