class ExtraUsersFields < ActiveRecord::Migration
  def change
    remove_column :users, :name

    add_column :users, :legacy_lender_id, :integer
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
    add_column :users, :created_by_legacy_id, :string
    add_column :users, :created_by_id, :integer
    add_column :users, :confirm_t_and_c, :boolean
    add_column :users, :modified_by_legacy_id, :string
    add_column :users, :modified_by_id, :integer
    add_column :users, :knowledge_resource, :boolean
    add_column :users, :legacy_id, :string
    add_column :users, :ar_timestamp, :datetime
    add_column :users, :ar_insert_timestamp, :datetime

    add_index :users, :legacy_id, unique: true
  end
end
