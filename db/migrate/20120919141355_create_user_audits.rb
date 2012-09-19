class CreateUserAudits < ActiveRecord::Migration
  def change
    create_table :user_audits do |t|
      t.references :user
      t.string :legacy_id
      t.integer :version
      t.integer :modified_by_id
      t.string :modified_by_legacy_id
      t.string :password
      t.string :function
      t.datetime :ar_timestamp
      t.datetime :ar_insert_timestamp
      t.timestamps
    end

    add_index :user_audits, :user_id
    add_index :user_audits, :modified_by_id
  end
end
