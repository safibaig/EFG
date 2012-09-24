class CreateAdminAudits < ActiveRecord::Migration
  def change
    create_table :admin_audits do |t|
      t.string :auditable_type, null: false
      t.integer :auditable_id, null: false
      t.integer :modified_by_id, null: false
      t.date :modified_on, null: false
      t.string :action, null: false

      t.integer :legacy_id
      t.string :legacy_object_id
      t.string :legacy_object_type
      t.integer :legacy_object_version
      t.string :legacy_modified_by
      t.string :ar_timestamp
      t.string :ar_insert_timestamp

      t.timestamps
    end
  end
end
