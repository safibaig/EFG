class ExtraUsersFields < ActiveRecord::Migration
  def up
    remove_column :users, :name

    add_column :users, :version, :integer
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :disabled, :boolean
    add_column :users, :memorable_name, :string
    add_column :users, :memorable_place, :string
    add_column :users, :memorable_year, :string
    add_column :users, :login_failures, :integer
    add_column :users, :password_changed_at, :datetime
    add_column :users, :locked, :boolean
    add_column :users, :created_by, :string
    add_column :users, :confirm_t_and_c, :boolean
    add_column :users, :modified_by, :string
    add_column :users, :knowledge_resource, :boolean
    add_column :users, :legacy_id, :string
    add_column :users, :ar_timestamp, :datetime
    add_column :users, :ar_insert_timestamp, :datetime

    add_index :users, :legacy_id, unique: true
  end

  def down
    add_column :users, :name, :string

    remove_column :users, :version
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :disabled
    remove_column :users, :memorable_name
    remove_column :users, :memorable_place
    remove_column :users, :memorable_year
    remove_column :users, :login_failures
    remove_column :users, :password_changed_at
    remove_column :users, :locked
    remove_column :users, :created_by
    remove_column :users, :confirm_t_and_c
    remove_column :users, :modified_by
    remove_column :users, :knowledge_resource
    remove_column :users, :legacy_id
    remove_column :users, :ar_timestamp
    remove_column :users, :ar_insert_timestamp
  end
end
